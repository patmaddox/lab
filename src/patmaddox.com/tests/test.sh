#!/bin/sh

set -eu

main() {
    rootdir=${1}; shift
    cd ${rootdir}

    if [ ! -f index.html ]; then
	echo "E: missing index.html" 1>&2
	exit 1
    fi
}

main "${@}"
