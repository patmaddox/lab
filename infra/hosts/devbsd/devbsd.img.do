#!/bin/sh
set -eu
set -o pipefail

exec >&2

version=16
pkgdir=../../../oss/freebsd-src/_build/current/pkgbase/FreeBSD:${version}:amd64/latest
distfiles=$(jj file list dist)

base_packages="
    FreeBSD-set-base
    FreeBSD-set-kernels
    FreeBSD-set-tests
"
extra_packages="
    ccache4
    perl5
    tmux
"

# redo secret sauce
redo-ifchange \
    ../../../oss/freebsd-src/targets/current/pkgbase \
    ${distfiles} \
    dist.mtree
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

    repoconfdir=$(mktemp -d -t devbsd-repo)
    cat > ${repoconfdir}/FreeBSD-base.conf <<EOF
FreeBSD-base: { url: "file://$(realpath ${pkgdir})", enabled: yes }
EOF
    cat > ${repoconfdir}/FreeBSD.conf <<EOF
FreeBSD: {
  url: "pkg+https://pkg.FreeBSD.org/\${ABI}/latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
EOF

    pkg_cmd="doas pkg --rootdir ${rootdir} --repo-conf-dir ${repoconfdir} -o ASSUME_ALWAYS_YES=yes -o IGNORE_OSVERSION=yes -o ABI=FreeBSD:${version}:amd64"

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
    doas zfs create -o mountpoint=/var -o canmount=off devbsd--zroot/var
    doas zfs create devbsd--zroot/var/db
    doas zfs create devbsd--zroot/var/run
    doas zfs create -o setuid=off -o exec=off devbsd--zroot/var/audit
    doas zfs create -o setuid=off -o exec=off devbsd--zroot/var/crash
    doas zfs create -o setuid=off -o exec=off devbsd--zroot/var/log
    doas zfs create -o atime=on devbsd--zroot/var/mail
    doas zfs create -o setuid=off devbsd--zroot/var/tmp
    doas zpool set bootfs=devbsd--zroot/ROOT/default devbsd--zroot
    doas zfs snapshot -r devbsd--zroot@init
}

install_base() {
    ${pkg_cmd} update
    ${pkg_cmd} install -U -r FreeBSD-base ${base_packages}
    ${pkg_cmd} install -r FreeBSD ${extra_packages}
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
#    doas zfs set readonly=on devbsd--zroot/ROOT/default
    doas zpool export devbsd--zroot || true
    [ -n "${mdid}" ] && doas mdconfig -d -u ${mdid} || true
    doas rm -rf ${rootdir} ${bootdir} ${repoconfdir}
}

main
