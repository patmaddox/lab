#!/bin/sh
set -eu

main() {
    outdir=${1}; shift
    contentdir=${1}; shift

    mkdir -p ${outdir}
    cp ${contentdir}/*.txt ${outdir}
    local p
    for p in $(ls ${contentdir}/*.md); do
	cp ${p} ${outdir}/$(basename ${p} .md).html
    done
}

main "${@}"
