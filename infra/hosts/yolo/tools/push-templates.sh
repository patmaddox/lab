#!/bin/sh
#
# push-templates.sh <pkg> ...
#
# Make a pkg repository of the templates' packages and sync it to
# /pkg/yolo on yolo, deleting what it no longer holds. Jails see it
# read-only as the repository yolo. Run it as just push-templates.
set -eu

host=yolo.p7x.dev

usage() {
	echo "usage: push-templates.sh <pkg> ..." >&2
	exit 64
}

[ ${#} -gt 0 ] || usage

stagedir=$(mktemp -d)
trap "rm -rf ${stagedir}" EXIT
# rsync gives /pkg/yolo the stage's mode, and jails' users read it.
chmod 0755 ${stagedir}

mkdir ${stagedir}/All
for pkg in "${@}"; do
	cp ${pkg} ${stagedir}/All/$(pkg query -F ${pkg} %n-%v).pkg
done
pkg repo -q ${stagedir}

rsync -a --delete ${stagedir}/ ${host}:/pkg/yolo/
