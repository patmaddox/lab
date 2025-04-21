#!/bin/sh
set -eu
set -o pipefail

main() {
    local outfile mdid

    freebsd_txz=${1}; shift
    outfile=${1}; shift
    tmpfile=${outfile}.tmp
    rm -f ${tmpfile}
    BUILDDIR=$(dirname ${outfile})
    rootdir=$(realpath ${BUILDDIR}/imgroot)
    distdir=$(realpath ${BUILDDIR}/../dist)

    build::validate-txz
    build::create-zpool
    build::extract
    build::config
    build::export-zpool
}

build::create-zpool() {
    truncate -s 20g ${tmpfile}
    mdid=$(doas mdconfig -a -f ${tmpfile} | grep -o '[[:digit:]]*')

    doas zpool create -m none -o autoexpand=on -t ninja-pb--zroot -R ${rootdir} zroot /dev/md${mdid}
    doas zfs create -o mountpoint=none ninja-pb--zroot/ROOT
    doas zfs create -o mountpoint=/ ninja-pb--zroot/ROOT/default
    doas zfs create -o mountpoint=/home ninja-pb--zroot/home
    doas zfs create -o mountpoint=/tmp -o exec=on -o setuid=off ninja-pb--zroot/tmp
    doas zfs create -o mountpoint=/usr -o canmount=off ninja-pb--zroot/usr
    doas zfs create -o setuid=off ninja-pb--zroot/usr/ports
    doas zfs create ninja-pb--zroot/usr/src
    doas zfs create ninja-pb--zroot/usr/obj
    doas zfs create -o mountpoint=/var -o canmount=off ninja-pb--zroot/var
    doas zfs create -o setuid=off -o exec=off ninja-pb--zroot/var/audit
    doas zfs create -o setuid=off -o exec=off ninja-pb--zroot/var/crash
    doas zfs create -o setuid=off -o exec=off ninja-pb--zroot/var/log
    doas zfs create -o atime=on ninja-pb--zroot/var/mail
    doas zfs create -o setuid=off ninja-pb--zroot/var/tmp
    doas zpool set bootfs=ninja-pb--zroot/ROOT/default ninja-pb--zroot

    doas zfs snapshot -r ninja-pb--zroot@init
}

build::validate-txz() {
    local p
    for p in base kernel; do
	test -f ${freebsd_txz}/${p}.txz
    done
}

build::extract() {
    local p
    for p in base kernel; do
	doas tar -C ${rootdir} -xf ${freebsd_txz}/${p}.txz
    done

    # /usr/src is an nfs mount point
    doas zfs set readonly=on ninja-pb--zroot/usr/src

    doas zfs snapshot -r ninja-pb--zroot@base
}

build::config() {
    # nfs mount points
    doas mkdir ${rootdir}/root/lab.jj

    tar -c -C ${distdir}/zroot @${distdir}/zroot.mtree | doas tar -x -C ${rootdir}
    doas zfs snapshot -r ninja-pb--zroot@config
}

build::export-zpool() {
    doas zpool export ninja-pb--zroot
    doas mdconfig -d -u ${mdid}
    mv ${tmpfile} ${outfile}
}

main "${@}"
