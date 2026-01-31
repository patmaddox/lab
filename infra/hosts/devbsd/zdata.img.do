#!/bin/sh
set -eu
set -o pipefail

exec >&2

distfiles=$(jj file list dist-zdata)

# redo secret sauce
redo-ifchange ${distfiles} dist-zdata.mtree
outfile=${3}
zpool=devbsd--zdata

main() {
    prepare_disk
    prepare_zpool
    install_config
}

prepare_disk() {
    rootdir=$(mktemp -d -t devbsd-data)

    truncate -s 100m ${outfile}
    md=$(doas mdconfig -a -f ${outfile})
    mdid=$(echo ${md} | grep -o '[[:digit:]]*')
    mdev=/dev/${md}

    trap 'exit 1' INT TERM
    trap cleanup EXIT
}

prepare_zpool() {
    doas zpool create -m none -o ashift=12 -o autoexpand=on -O compression=on -t ${zpool} -R ${rootdir} zdata ${mdev}
    doas zfs create -o mountpoint=/usr -o canmount=off ${zpool}/usr
    doas zfs create ${zpool}/usr/obj
    doas zfs create -o mountpoint=/var -o canmount=off ${zpool}/var
    doas zfs create -o setuid=off -o canmount=off ${zpool}/var/tmp
    doas zfs create ${zpool}/var/tmp/ccache
    doas zfs snapshot -r ${zpool}@init
}

install_config() {
    distmtree=$(realpath dist-zdata.mtree)
    tar -c -C dist-zdata @${distmtree} | doas tar -x -C ${rootdir}
    doas zfs snapshot -r ${zpool}@config
}

cleanup() {
    doas zpool export ${zpool} || true
    [ -n "${mdid}" ] && doas mdconfig -d -u ${mdid} || true
    doas rm -rf ${rootdir}
}

main
