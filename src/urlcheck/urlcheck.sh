#!/bin/sh
set -eu

main() {
    host=${1}; shift
    url=${1}; shift

    /home/patmaddox/go/bin/muffet --color=never -i ${host} ${url}
}

main "${@}"
