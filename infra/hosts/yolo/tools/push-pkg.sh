#!/bin/sh
#
# push-pkg.sh <pkg> ...
#
# Copy packages to /tmp on yolo, each named <name>-<version>.pkg as
# read from the package itself. pkg add of one of them then finds its
# dependencies beside it under those names. Run it as just push-pkg.
set -eu

host=root@yolo.p7x.dev

usage() {
	echo "usage: push-pkg.sh <pkg> ..." >&2
	exit 64
}

[ ${#} -gt 0 ] || usage

for pkg in "${@}"; do
	scp -q ${pkg} ${host}:/tmp/$(pkg query -F ${pkg} %n-%v).pkg
done
