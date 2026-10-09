#!/bin/sh
set -eu
set -o pipefail

. workspace.subr

if [ -z "${name}" ]; then
	echo "E: name was not set" >&2
	exit 1
fi

_jail_login() {
	TERM=xterm-256color doas jexec -l ${name} login -f "${1:-${defaultuser}}"
}

cmd=${1}; shift
_jail_${cmd} "${@}"
