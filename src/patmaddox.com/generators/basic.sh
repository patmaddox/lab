#!/bin/sh
set -eu

main() {
    outdir=${1}; shift
    contentdir=${1}; shift

    mkdir -p ${outdir}
    touch ${outdir}/index.html
}

main "${@}"
