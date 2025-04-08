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

    doas zpool create -m none -o autoexpand=on -t ninja--zroot -R ${rootdir} zroot /dev/md${mdid}
    doas zfs create -o mountpoint=none ninja--zroot/ROOT
    doas zfs create -o mountpoint=/ ninja--zroot/ROOT/default
    doas zfs create -o mountpoint=/home ninja--zroot/home
    doas zfs create -o mountpoint=/tmp -o exec=on -o setuid=off ninja--zroot/tmp
    doas zfs create -o mountpoint=/usr -o canmount=off ninja--zroot/usr
    doas zfs create -o setuid=off ninja--zroot/usr/ports
    doas zfs create ninja--zroot/usr/src
    doas zfs create ninja--zroot/usr/obj
    doas zfs create -o mountpoint=/var -o canmount=off ninja--zroot/var
    doas zfs create -o setuid=off -o exec=off ninja--zroot/var/audit
    doas zfs create -o setuid=off -o exec=off ninja--zroot/var/crash
    doas zfs create -o setuid=off -o exec=off ninja--zroot/var/log
    doas zfs create -o atime=on ninja--zroot/var/mail
    doas zfs create -o setuid=off ninja--zroot/var/tmp
    doas zpool set bootfs=ninja--zroot/ROOT/default ninja--zroot

    doas zfs snapshot -r ninja--zroot@init
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
    doas zfs set readonly=on ninja--zroot/usr/src

    doas zfs snapshot -r ninja--zroot@base
}

build::config() {
    # nfs mount points
    doas mkdir ${rootdir}/root/lab.jj

    tar -c -C ${distdir}/zroot @${distdir}/zroot.mtree | doas tar -x -C ${rootdir}
    doas zfs snapshot -r ninja--zroot@config
}

build::export-zpool() {
    doas zpool export ninja--zroot
    doas mdconfig -d -u ${mdid}
    mv ${tmpfile} ${outfile}
}

main "${@}"
