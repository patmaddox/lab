#!/bin/sh
set -eu
set -o pipefail

readonly jailsdir=$(realpath $(dirname $(realpath ${0}))/..)
. instance.conf
. ${jailsdir}/libexec/jail.subr

if [ -z "${name}" ]; then
	echo "E: name was not set" >&2
	exit 1
fi

_jail_login() {
	local user="${1:-${defaultuser:-root}}"

	if ! doas jexec -l ${name} pw user show -n "${user}" >/dev/null 2>&1; then
		echo "E: no such user ${user}" >&2
		exit 1
	fi
	doas jexec -l ${name} env \
	    COLORTERM=${COLORTERM:} \
	    INSIDE_EMACS=${INSIDE_EMACS:} \
	    login -fp "${user}"
}

cmd=${1}; shift
_jail_${cmd} "${@}"
