#!/bin/sh
set -eu
set -o pipefail

. workspace.subr

exec >&2

if zfs list ${wroot} >/dev/null 2>&1; then
	doas zfs destroy ${wroot}
fi

rm -f jail.log
