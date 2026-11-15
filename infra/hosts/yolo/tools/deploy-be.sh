#!/bin/sh
#
# deploy-be.sh <config> <stream>
#
# Import a boot environment stream on yolo as
# <name>-<release>-<version>-new, e.g. yolo-15.1-2026.11.09.143005-new,
# and activate it for the next boot only. <config> sets name and
# release, and the version is the time the stream was built, in UTC.
# The stream goes over ssh straight into bectl import, so it never
# lands on yolo's disk.
# Run it as just deploy-be.
set -eu

host=root@yolo.p7x.dev

usage() {
	echo "usage: deploy-be.sh <config> <stream>" >&2
	exit 64
}

[ ${#} -eq 2 ] || usage
config=$(realpath ${1})
stream=${2}

. ${config}
: ${name:?} ${release:?}

be=${name}-${release}-$(TZ=UTC stat -f %Sm -t %Y.%m.%d.%H%M%S ${stream})-new

ssh ${host} bectl import ${be} < ${stream}
ssh ${host} bectl activate -t ${be}
