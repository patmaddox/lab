#!/bin/sh
#
# zfs receive -o origin=<snapshot> and then promote method is described in
# https://github.com/openzfs/zfs/discussions/10325?sort=old#discussioncomment-232840
set -eu
set -o pipefail

main() {
    local image_name image_file dist_mtree mountpoint
    image_name=${1:?E: $(usage)}; shift
    image_file=${1:?E: $(usage)}; shift
    dist_mtree=${1:?E: $(usage)}; shift
    dist_mtree=$(realpath ${dist_mtree})

    receive-image
    config-image
    stop-jail
    move-children
    promote
    start-jail
}

receive-image() {
    mountpoint=$(zfs get -H -o value mountpoint zroot/jails/${image_name})

    local snapshot
    snapshot=$(zfs list -H -S creation -t snap zroot/jails/${image_name} | head -n 1 | awk '{print $1}')

    if [ -z "${snapshot}" ]; then
	echo "E: no snapshot for zroot/jails/${image_name}" 1>&2
	exit 1
    fi

    gzcat ${image_file} | zfs receive -x mountpoint -o origin=${snapshot} zroot/jails/${image_name}-next
}

config-image() {
    local dist_dir
    dist_dir=$(dirname ${dist_mtree})
    tar -c -C ${dist_dir} @${dist_mtree} | tar -x -C ${mountpoint}-next
}

stop-jail() {
    service jail onestop ${image_file}
}

move-children() {
    if [ "$(zfs get -H -o value mounted zroot/jails/${image_name})" = "yes" ]; then
	zfs umount zroot/jails/${image_name}
    fi
    zfs set canmount=off zroot/jails/${image_name}

    local fs d
    for fs in $(zfs list -H -d 1 -t filesystem -o name zroot/jails/${image_name} | tail +2); do
	d=$(basename ${fs})
	zfs rename ${fs} zroot/jails/${image_name}-next/${d}
    done
}

promote() {
    zfs rename zroot/jails/${image_name} zroot/jails/${image_name}-old
    zfs rename zroot/jails/${image_name}-next zroot/jails/${image_name}
    zfs promote zroot/jails/${image_name}
}

start-jail() {
    zfs set canmount=on zroot/jails/${image_name}
    zfs mount -R zroot/jails/${image_name}
    service jail onestart ${image_name}
}

usage() {
    echo "Usage: deploy.sh <image_name> <image_file> <dist.mtree>"
}

main "${@}"
