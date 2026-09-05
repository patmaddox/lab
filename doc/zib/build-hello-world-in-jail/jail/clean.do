#!/bin/sh
set -eu
set -o pipefail

exec >&2

readonly name=$(./jailname.sh)
if [ -z "${name}" ]; then
	echo "E: name was not set"
	exit 1
fi

if jls -c -j ${name}; then
	echo "E: cannot clean ${name} because it is still running"
	exit 1
fi

readonly jailroot="/tmp/jails/${name}"

if [ -d ${jailroot} ]; then
	doas chflags -R noschg ${jailroot}
	doas rm -rf ${jailroot}
fi

rm -f tmp/build_jail.log vars.conf
