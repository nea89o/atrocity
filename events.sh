atrocity_on_dispatch() {
	local event
	event="$(printf '%s' "$1" | jq -r .t)"
	atrocity_on_event "$event" "$(printf '%s' "$1" | jq .d)"
}

atrocity_on_event() {
	atrocity_on_default_event "$1" "$2"
}
atrocity_on_default_event() {
	local handler
	handler="atrocity_on_$1"
	if declare -F "$handler" >/dev/null; then
		"$handler" "$2"
	else
		atrocity_on_unknown "$1" "$2"
	fi
}

atrocity_on_unknown() {
	noop
}
