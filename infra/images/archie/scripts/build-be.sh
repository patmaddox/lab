#!/bin/sh
set -eu
set -o pipefail

main() {
    local image_name jail_name portsfile outfile

    image_name=${1:?$(usage)}; shift
    jail_name=${1:?$(usage)}; shift
    portsfile=${1:?$(usage)}; shift
    outfile=${1:?$(usage)}; shift

    scp ${portsfile} root@poudriere:/tmp/${image_name}-${jail_name}.ports
    ssh -t root@poudriere "poudriere image -j ${jail_name} -t zsnapshot -f /tmp/${image_name}-${jail_name}.ports -n ${image_name}-${jail_name} -S next"
    scp root@poudriere:/usr/local/poudriere/data/images/${image_name}-${jail_name}-next.full.img.gz ${outfile}
}

usage() {
    echo "Usage: build-be.sh <image_name> <jail_name> <portsfile> <outfile>"
}

main "${@}"
