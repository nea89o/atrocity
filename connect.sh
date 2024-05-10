_atrocity_prepare() {
	ATROCITY_SESSION="$(mktemp -d)"
	export ATROCITY_SESSION
	atrocity_debug "Preparing session in $ATROCITY_SESSION"
	# shellcheck disable=SC2064
	trap "rm -fr '$ATROCITY_SESSION'" EXIT
	mkdir "$ATROCITY_SESSION"/online
	printf null >"$ATROCITY_SESSION"/sequence
	mkdir "$ATROCITY_SESSION"/write-queue
	mkdir "$ATROCITY_SESSION"/write-buffer
	echo 10 >"$ATROCITY_SESSION"/heartbeat-interval
}

atrocity_connect() {
	if [ -e "$ATROCITY_SESSION"/connection-started ]; then
		atrocity_debug "Atrocity loop has already been set up"
		exit 1
	fi
	touch "$ATROCITY_SESSION"/connection-started
	mkfifo "$ATROCITY_SESSION"/raw-write-queue
	mkfifo "$ATROCITY_SESSION"/raw-read-queue

	(
		atrocity_debug "Write queue started" "$ATROCITY_SESSION/raw-write-queue"
		while atrocity_is_online; do
			find "$ATROCITY_SESSION"/write-queue -type l |
				while read -r message; do
					cat "$message"
					atrocity_debug "Sending message $message: $(cat -- "$message")"
					rm -f "$(readlink -f "$message")"
					rm -f "$message"
				done
		done >"$ATROCITY_SESSION/raw-write-queue"
		atrocite_debug "Exiting write queue"
	) &
	(
		atrocity_debug "Heartbeat queue started"
		while atrocity_is_online; do
			atrocity_heartbeat
			sleep "$(cat "$ATROCITY_SESSION"/heartbeat-interval)"
		done
	) &

	(
		atrocity_debug "Websocket connected"
		websocat wss://gateway.discord.gg/
		atrocity_debug "Websocket disconnected"
	) <"$ATROCITY_SESSION/raw-write-queue" >"$ATROCITY_SESSION/raw-read-queue" &
}
atrocity_heartbeat() {
	atrocity_debug "Heartbeating"
	atrocity_gateway_send_raw '{"op":1,"d":'"$(atrocity_sequence_get)"'}'
}

atrocity_gateway_send_raw() {
	local file

	file="$(mktemp -p "$ATROCITY_SESSION"/write-buffer)"
	printf "%s\n" "${*}" >"$file"
	ln -s "$file" "$ATROCITY_SESSION/write-queue"
}
atrocity_sequence_get() {
	cat "$ATROCITY_SESSION"/sequence
}

atrocity_is_online() {
	[[ -d "$ATROCITY_SESSION"/online ]]
	return $?
}

atrocity_loop() {
	if ! [ -e "$ATROCITY_SESSION"/connection-started ]; then
		atrocity_debug "Atrocity loop started before connection has been set up"
		exit 1
	fi
	atrocity_debug "Loop started"
	while true; do
		local line
		local operator
		atrocity_debug "Trying to read line"
		if read -r line; then
			atrocity_debug "Reading message from discord: $line"

			printf %s "$line" | jq 'if .s then .s else '"$(atrocity_sequence_get)"' end' >"$ATROCITY_SESSION"/sequence
			operator="$(printf %s "$line" | jq .op)"
			case "$operator" in
			9) # Invalid session
				atrocity_debug "Received invalid session: $line"
				exit 1
				;;
			10) # Hello
				atrocity_debug "Sending hello"
				echo "$(($(printf "%s" "$line" | jq -r .d.heartbeat_interval) / 1000))" >"$ATROCITY_SESSION"/heartbeat-interval
				atrocity_gateway_send_raw '{"op":2,"d":{"token":"'$ATROCITY_TOKEN'", "properties":{"os":"linux","browser":"bash","device":"bash"},"presence":{"status":"online","afk":false, "activities":[{"type":0,"name":"Being coded in Bash"}]}, "intents":33287}}'
				;;
			0) # Dispatch
				atrocity_dispatch "$line"
				;;
			1) # Heartbeat
				atrocity_heartbeat
				;;
			11) # Heartbeat ACK
				# TODO: Check for zombie connections
				atrocity_debug "Heartbeat ACK"
				;;
			*)
				atrocity_debug "Unhandled operator $operator"
				;;
			esac
		fi
	done <"$ATROCITY_SESSION"/raw-read-queue
}
