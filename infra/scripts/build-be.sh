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
    ssh -t root@poudriere "poudriere image -j ${jail_name} -p main -t zfs+send+be -f /tmp/${image_name}-${jail_name}.ports -n ${image_name}${jail_name} -s 20G"
    scp root@poudriere:/usr/local/poudriere/data/images/${image_name}${jail_name}.be.zfs ${outfile}.tmp
    mv ${outfile}.tmp ${outfile}
}

usage() {
    echo "Usage: build-be.sh <image_name> <jail_name> <portsfile> <outfile>"
}

main "${@}"
