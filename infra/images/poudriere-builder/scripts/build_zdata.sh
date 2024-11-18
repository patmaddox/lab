#!/bin/sh
set -eu

main() {
    outzfs=${BUILDDIR}/zdata.zfs
    truncate -s 100m ${outzfs}
    mdid=$(mdconfig -a -f ${outzfs} | grep -o '[[:digit:]]*')

    rootdir=${BUILDDIR}/root
    mkdir ${rootdir}
    rootdir=$(realpath ${rootdir})

    zpool create -m none -o autoexpand=on -t plz-pb--zdata -R ${rootdir} zdata /dev/md${mdid}
    zfs create -o mountpoint=/usr -o canmount=off plz-pb--zdata/usr
    zfs create -o canmount=off plz-pb--zdata/usr/local
    zfs create plz-pb--zdata/usr/local/poudriere
    zpool export plz-pb--zdata
    mdconfig -d -u ${mdid}

    mkimg -s gpt \
	  -p freebsd-zfs:=${outzfs} -o ${BUILDDIR}/zdata.img --capacity 101M
}

main
