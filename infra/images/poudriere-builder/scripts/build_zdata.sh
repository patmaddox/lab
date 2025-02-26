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
    zfs create -o mountpoint=/usr/local/poudriere plz-pb--zdata/poudriere-data
    zfs create -o mountpoint=/usr/local/etc/poudriere.d plz-pb--zdata/etc-poudriere-d
    tar -c -C ${DISTDIR} . | tar -x -C ${rootdir} --gid 0 --uid 0
    zfs snapshot -r plz-pb--zdata@init
    zpool export plz-pb--zdata
    mdconfig -d -u ${mdid}

    mkimg -s gpt \
	  -p freebsd-zfs:=${outzfs} -o ${BUILDDIR}/zdata.img --capacity 101M
}

main
