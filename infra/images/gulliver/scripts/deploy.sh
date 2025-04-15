#!/bin/sh
set -eu
set -o pipefail

TOOL_SYNC_PW=$(realpath ${TOOL_SYNC_PW:?E: $(usage)})

main() {
    local image_name image_file dist_mtree data_mtree tz
    local mountpoint tmp_image_name

    image_name=${1:?E: $(usage)}; shift
    image_file=${1:?E: $(usage)}; shift
    dist_mtree=${1:?E: $(usage)}; shift
    data_mtree=${1:?E: $(usage)}; shift
    tz=${1:?E: $(usage)}; shift

    dist_mtree=$(realpath ${dist_mtree})
    data_mtree=$(realpath ${data_mtree})

    tmp_image_name=TMP-${image_name}-next

    import-be
    config-be
    sync-pw
    unmount-be
}

import-be() {
    bectl import ${tmp_image_name} < ${image_file}
}

config-be() {
    local dist_dir

    mountpoint=$(bectl mount ${tmp_image_name})
    dist_dir=$(dirname ${dist_mtree})
    tar -c -C ${dist_dir} @${dist_mtree} | tar -x -C ${mountpoint}

    # This is tight coupling, setting data_mtree to read from /. But
    # it will work for now
    tar -C / -c @${data_mtree} | tar -x -C ${mountpoint}

    tzsetup -C ${mountpoint} ${tz}
}

# when we code, we code hard
sync-pw() {
    local u g

    for u in root patmaddox; do
	${TOOL_SYNC_PW} /etc ${mountpoint}/etc u ${u}
    done

    for g in operator patmaddox video wheel; do
	${TOOL_SYNC_PW} /etc ${mountpoint}/etc g ${g}
    done
}

unmount-be() {
    local revision
    revision=$(chroot ${mountpoint} freebsd-version -u)
    bectl umount ${tmp_image_name}
    bectl rename ${tmp_image_name} NEW-${image_name}-${revision}
}

usage() {
    echo "Usage: TOOL_PW_SYNC=path/sync-pw deploy.sh <image_name> <image_file> <dist.mtree> <data.mtree> <timezone>"
}

main "${@}"
