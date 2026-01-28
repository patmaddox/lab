#!/bin/sh
set -eu
set -o pipefail

: ${ABI}
: ${PKGBASE_DIR}

DOAS=doas
outfile=${1}; shift
major_version=$(echo "${ABI}" | cut -d ':' -f 2)

main() {
    prepare_disk
    prepare_zpool
    install_base
    install_config
    install_bootloader
}

prepare_disk() {
    rootdir=$(mktemp -d -t poudriere)
    bootdir=${rootdir}-boot
    mkdir ${bootdir}

    pkg_cmd="doas env ABI=${ABI} IGNORE_OSVERSION=yes pkg -r ${rootdir}"

    truncate -s 1300m ${outfile}
    md=$(doas mdconfig -a -f ${outfile})
    mdid=$(echo ${md} | grep -o '[[:digit:]]*')
    mdev=/dev/${md}

    trap 'exit 1' INT TERM
    trap cleanup EXIT

    doas gpart create -s gpt ${md}
    doas gpart add -t efi -s 260m -l efi ${md}
    doas gpart add -t freebsd-zfs -l zroot ${md}
}

prepare_zpool() {
    # from freebsr-src/release/tools/vmimage.subr
    doas zpool create -m none -o ashift=12 -o autoexpand=on -O compression=on -t poudriere--zroot -R ${rootdir} zroot ${mdev}p2
    doas zfs create -o mountpoint=none poudriere--zroot/ROOT
    doas zfs create -o mountpoint=/ poudriere--zroot/ROOT/default
    doas zfs create -o mountpoint=/home poudriere--zroot/home
    doas zfs create -o mountpoint=/tmp -o exec=on -o setuid=off poudriere--zroot/tmp
    doas zfs create -o mountpoint=/usr -o canmount=off poudriere--zroot/usr
    doas zfs create -o setuid=off poudriere--zroot/usr/ports
    doas zfs create -o mountpoint=/var -o canmount=off poudriere--zroot/var
    doas zfs create -o setuid=off -o exec=off poudriere--zroot/var/audit
    doas zfs create -o setuid=off -o exec=off poudriere--zroot/var/crash
    doas zfs create -o setuid=off -o exec=off poudriere--zroot/var/log
    doas zfs create -o atime=on poudriere--zroot/var/mail
    doas zfs create -o setuid=off poudriere--zroot/var/tmp
    doas zpool set bootfs=poudriere--zroot/ROOT/default poudriere--zroot
    doas zfs snapshot -r poudriere--zroot@init
}

install_base() {
    ${pkg_cmd} add ${PKGBASE_DIR}/FreeBSD-set-base-${major_version}.*.pkg
    ${pkg_cmd} add ${PKGBASE_DIR}/FreeBSD-set-kernels-${major_version}.*.pkg
    ${pkg_cmd} add ${PKGBASE_DIR}/FreeBSD-set-tests-${major_version}.*.pkg
    ${pkg_cmd} install -r FreeBSD -y poudriere-devel tmux
    doas zfs snapshot -r poudriere--zroot@base
}

install_config() {
    # nfs mount point
    doas mkdir ${rootdir}/root/lab.jj

    # config
    distmtree=$(realpath dist.mtree)
    tar -c -C dist @${distmtree} | doas tar -x -C ${rootdir}
    doas zfs snapshot -r poudriere--zroot@config
}

install_bootloader() {
    doas newfs_msdos -F 32 -c 1 ${mdev}p1
    doas mount -t msdosfs ${mdev}p1 ${bootdir}
    doas mkdir -p ${bootdir}/EFI/BOOT
    doas cp ${rootdir}/boot/loader.efi ${bootdir}/EFI/BOOT/BOOTX64.EFI
    doas umount ${bootdir}
}

cleanup() {
    doas zfs set readonly=on poudriere--zroot/ROOT/default
    doas zpool export poudriere--zroot || true
    [ -n "${mdid}" ] && doas mdconfig -d -u ${mdid} || true
    doas rm -rf ${rootdir} ${bootdir}
}

trap cleanup EXIT
main
