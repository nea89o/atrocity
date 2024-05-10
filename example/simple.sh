#!/usr/bin/env bash
source "$(dirname -- "$0")"/../load.sh

atrocity_debug Simple example loaded

export ATROCITY_TOKEN="MzEyMjU2ODcxMTc0MTExMjMz.GPe_v6.4Acwm7tje3sMEvUu05NPyQrZalh8knTIHPgLmk"

atrocity_dispatch() {
	echo "Dispatching $1"
}

atrocity_connect

atrocity_loop
