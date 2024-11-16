#!/bin/sh
set -eu

main() {
    local freebsd_txz outfile distfiles

    freebsd_txz=${1}; shift
    outfile=${1}; shift

    rootzfs=${BUILDDIR}/root.zfs
    rootdir=${BUILDDIR}/imgroot
    mkdir ${rootdir}

    build::extract
    build::makefs

    mv ${rootzfs} ${BUILDDIR}/${outfile}
}

build::extract() {
    tar -C ${rootdir} -xf ${freebsd_txz}/base.txz
    tar -C ${rootdir} -xf ${freebsd_txz}/kernel.txz
}

build::makefs() {
    makefs -t zfs -s 10g \
	   -o poolname=zroot -o bootfs=zroot/ROOT/default -o rootpath=/ \
	   -o fs=zroot\;mountpoint=none \
	   -o fs=zroot/ROOT\;mountpoint=none \
	   -o fs=zroot/ROOT/default\;mountpoint=/ \
	   -o fs=zroot/home\;mountpoint=/home \
	   -o fs=zroot/tmp\;mountpoint=/tmp\;exec=on\;setuid=off \
	   -o fs=zroot/usr\;mountpoint=/usr\;canmount=off \
	   -o fs=zroot/usr/ports\;setuid=off \
	   -o fs=zroot/var\;mountpoint=/var\;canmount=off \
	   -o fs=zroot/var/audit\;setuid=off\;exec=off \
	   -o fs=zroot/var/crash\;setuid=off\;exec=off \
	   -o fs=zroot/var/log\;setuid=off\;exec=off \
	   -o fs=zroot/var/mail\;atime=on \
	   -o fs=zroot/var/tmp\;setuid=off \
	   ${rootzfs} ${rootdir}
}

main "${@}"
