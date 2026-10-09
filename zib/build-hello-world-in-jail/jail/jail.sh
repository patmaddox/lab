#!/bin/sh
set -eu
set -o pipefail

readonly name=$(./jailname.sh)
if [ -z "${name}" ]; then
	echo "E: name was not set" >&2
	exit 1
fi

_start() {
	redo-ifchange vars.conf
	jls -c -j ${name} || doas jail -f jail.conf -c ${name}
}

_stop() {
	redo-ifchange vars.conf
	if jls -c -j ${name}; then doas jail -f jail.conf -r ${name}; fi
}

_login() {
	TERM=xterm-256color doas jexec -l ${name} login -f root
}

_${1}
