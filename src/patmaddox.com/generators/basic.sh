#!/bin/sh
set -eu

main() {
    outdir=${1}; shift
    contentdir=${1}; shift

    mkdir -p ${outdir}
    echo "This is my home page" > ${outdir}/index.html
}

main "${@}"
