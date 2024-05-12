#!/usr/bin/env bash
source "$(dirname -- "$0")"/env.sh
source "$(dirname -- "$0")"/../load.sh

atrocity_debug Simple example loaded
atrocity_on_GUILD_CREATE() {
	atrocity_debug "Guild: $(echo "$1" | jq -r .name)"
}
atrocity_on_unknown() {
	atrocity_debug "Unknown event $1"
}
atrocity_on_MESSAGE_CREATE() {
	local content
	local channel
	content="$(echo "$1" | jq -r .content)"
	channel="$(echo "$1" | jq -r .channel_id)"

	if [[ "$(echo "$1" | jq -r .author.bot)" = "true" ]]; then
		return
	fi
	atrocity_debug "Found message with content $content"

	case "$content" in
	\!ping)
		atrocity_rest POST /channels/"$channel"/messages '{"content": "Pong", "embeds": [{"title": "Pong", "description": "You have been ponginated"}]}'
		;;
	esac
}

atrocity_connect

atrocity_loop
