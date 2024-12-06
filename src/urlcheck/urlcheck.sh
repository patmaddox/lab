#!/bin/sh
set -eu

muffet=${MUFFET:-muffet}

main() {
    host=${1}; shift
    url=${1}; shift

    ${muffet} --color=never -i ${host} ${url}
}

main "${@}"
