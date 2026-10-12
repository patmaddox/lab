#!/bin/sh
set -eu
set -o pipefail

: ${ABI}

outfile=${1}; shift

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

    pkgbase_cmd="doas env ABI=${ABI} IGNORE_OSVERSION=yes pkg -r ${rootdir} -R $(realpath repos)"
    pkg_cmd="doas env ABI=${ABI} IGNORE_OSVERSION=yes pkg -c ${rootdir}"

    truncate -s 2500m ${outfile}
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
	doas mkdir ${rootdir}/etc/
	echo "nameserver 8.8.8.8" | doas tee ${rootdir}/etc/resolv.conf >/dev/null

	doas mkdir -p ${rootdir}/usr/share/keys/pkg/trusted/
	doas fetch -q -o ${rootdir}/usr/share/keys/pkg/trusted/ https://cgit.freebsd.org/src/plain/share/keys/pkg/trusted/pkg.freebsd.org.2013102301

	${pkgbase_cmd} install -r FreeBSD-base -y \
	    FreeBSD-set-base \
	    FreeBSD-set-kernels \
	    FreeBSD-set-tests

	${pkg_cmd} install -r FreeBSD-ports -y \
            deskutils/just \
            net/rsync \
            ports-mgmt/pkg \
            ports-mgmt/poudriere-devel \
            sysutils/htop \
            sysutils/tmux \
            www/nginx
	doas zfs snapshot -r poudriere--zroot@base
}

install_config() {
    # nfs mount point
    doas mkdir ${rootdir}/root/lab

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
    doas zpool export poudriere--zroot || true
    [ -n "${mdid}" ] && doas mdconfig -d -u ${mdid} || true
    doas rm -rf ${rootdir} ${bootdir}
}

trap cleanup EXIT
main
