#!/bin/sh
#
# deploy-be.sh <config> <stream>
#
# Import a boot environment stream on yolo as
# <name>-<release>-<date>-new, e.g. yolo-15.1-2026-11-09-new, and
# activate it for the next boot only. <config> sets name and release,
# and the date is the day the stream was built. The stream goes over
# ssh straight into bectl import, so it never lands on yolo's disk.
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

be=${name}-${release}-$(stat -f %Sm -t %Y-%m-%d ${stream})-new

ssh ${host} bectl import ${be} < ${stream}
ssh ${host} bectl activate -t ${be}
