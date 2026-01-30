#!/bin/sh
set -eu
set -o pipefail

exec >&2

version=16
pkgdir=../../../ninja-out/oss/freebsd-src/current/pkgbase/FreeBSD:${version}:amd64/latest
sources=$(ls ${pkgdir}/FreeBSD-*.pkg)
distfiles=$(jj file list dist)

# redo secret sauce
redo-ifchange ${sources} ${distfiles}
outfile=${3}

main() {
    prepare_disk
    prepare_zpool
    install_base
    install_config
    install_bootloader
}

prepare_disk() {
    rootdir=$(mktemp -d -t devbsd)
    bootdir=${rootdir}-boot
    mkdir ${bootdir}

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
    doas zpool create -m none -o ashift=12 -o autoexpand=on -O compression=on -t devbsd--zroot -R ${rootdir} zroot ${mdev}p2
    doas zfs create -o mountpoint=none devbsd--zroot/ROOT
    doas zfs create -o mountpoint=/ devbsd--zroot/ROOT/default
    doas zfs create -o mountpoint=/home devbsd--zroot/home
    doas zfs create -o mountpoint=/tmp -o exec=on -o setuid=off devbsd--zroot/tmp
    doas zfs create -o mountpoint=/usr -o canmount=off devbsd--zroot/usr
    doas zfs create -o setuid=off devbsd--zroot/usr/ports
    doas zfs create devbsd--zroot/usr/src
    doas zfs create devbsd--zroot/usr/obj
    doas zfs create -o mountpoint=/var -o canmount=off devbsd--zroot/var
    doas zfs create -o setuid=off -o exec=off devbsd--zroot/var/audit
    doas zfs create -o setuid=off -o exec=off devbsd--zroot/var/crash
    doas zfs create -o setuid=off -o exec=off devbsd--zroot/var/log
    doas zfs create -o atime=on devbsd--zroot/var/mail
    doas zfs create -o setuid=off devbsd--zroot/var/tmp
    doas zpool set bootfs=devbsd--zroot/ROOT/default devbsd--zroot
    doas zfs snapshot -r devbsd--zroot@init
}

install_base() {
    pkg_cmd="doas env ABI=FreeBSD:${version}:amd64 IGNORE_OSVERSION=yes pkg -r ${rootdir}"
    ${pkg_cmd} add $(realpath ${pkgdir}/FreeBSD-set-base-${version}.*.pkg)
    ${pkg_cmd} add $(realpath ${pkgdir}/FreeBSD-kernel-*-${version}.*.pkg)
    doas zfs snapshot -r devbsd--zroot@base
}

install_config() {
    # nfs mount point
    doas mkdir ${rootdir}/root/lab.jj

    # config
    distmtree=$(realpath dist.mtree)
    tar -c -C dist @${distmtree} | doas tar -x -C ${rootdir}
    doas zfs snapshot -r devbsd--zroot@config
}

install_bootloader() {
    doas newfs_msdos -F 32 -c 1 ${mdev}p1
    doas mount -t msdosfs ${mdev}p1 ${bootdir}
    doas mkdir -p ${bootdir}/EFI/BOOT
    doas cp ${rootdir}/boot/loader.efi ${bootdir}/EFI/BOOT/BOOTX64.EFI
    doas umount ${bootdir}
}

cleanup() {
    doas zpool export devbsd--zroot || true
    [ -n "${mdid}" ] && doas mdconfig -d -u ${mdid} || true
    rmdir ${rootdir} ${bootdir} || true
}

main
