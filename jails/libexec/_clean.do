#!/bin/sh
set -eu
set -o pipefail

readonly jailsdir=$(realpath $(dirname $(realpath ${0}))/..)
. instance.conf
. ${jailsdir}/libexec/jail.subr

exec >&2

if _is_running; then
	echo "E: ${name} is running" >&2
	exit 1
fi

if zfs list ${wroot} >/dev/null 2>&1; then
	doas zfs destroy ${wroot}
fi

rm -f jail.log
