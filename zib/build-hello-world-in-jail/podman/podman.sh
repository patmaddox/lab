#!/bin/sh
set -eu
set -o pipefail

readonly name="hello-podman"

_exists() {
	test -n "$(doas podman ps --noheading -a -f name=${name} ${@})"
}

_is_running() {
	_exists -f status=running
}

_start() {
	if _is_running; then
		return 0
	elif _exists; then
		doas podman start ${name}
	else
		doas podman run -d \
		    --name ${name} \
		    --hostname ${name} \
		    --network host \
		    --no-hosts \
		    --dns=8.8.8.8 \
		    ${name}
	fi
}

_stop() {
	if _is_running; then doas podman stop ${name} >/dev/null; fi
}

_login() {
	doas podman exec -it ${name} login -f root
}

_${1}
