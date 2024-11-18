#!/bin/sh
set -eu

main() {
    local freebsd_txz outfile distfiles

    freebsd_txz=${1}; shift
    distfiles=${1}; shift
    outfile=${1}; shift

    outfileroot=${BUILDDIR}/${outfile}.zfs
    rootdir=${BUILDDIR}/imgroot
    mkdir ${rootdir}

    build::extract
    build::config
    build::freebsd-rel
    build::img-root
}

build::extract() {
    local p
    for p in base kernel src; do
	tar -C ${rootdir} -xf ${freebsd_txz}/${p}.txz
    done

    mkdir ${rootdir}/usr/ports
    tar -c -C ${PORTSDIR} . | tar -x -C ${rootdir}/usr/ports --gid 0 --uid 0
}

build::config() {
    tar -c -C ${distfiles} . | tar -x -C ${rootdir} --gid 0 --uid 0
}

build::freebsd-rel() {
    mkdir -p ${rootdir}/opt/distfiles/freebsd-rel

    local rel cleanname
    for rel in ${FREEBSD_REL}; do
	cleanname=$(basename ${rel} | sed -e 's/^rel--//')
	mv ${rel} ${rootdir}/opt/distfiles/freebsd-rel/${cleanname}
    done
}

build::img-root() {
    makefs -t zfs -s 20g \
	   -o poolname=zroot -o bootfs=zroot/ROOT/default -o rootpath=/ \
	   -o fs=zroot\;mountpoint=none \
	   -o fs=zroot/ROOT\;mountpoint=none \
	   -o fs=zroot/ROOT/default\;mountpoint=/ \
	   -o fs=zroot/home\;mountpoint=/home \
	   -o fs=zroot/tmp\;mountpoint=/tmp\;exec=on\;setuid=off \
	   -o fs=zroot/usr\;mountpoint=/usr\;canmount=off \
	   -o fs=zroot/usr/ports\;setuid=off \
	   -o fs=zroot/usr/src \
	   -o fs=zroot/usr/obj \
	   -o fs=zroot/var\;mountpoint=/var\;canmount=off \
	   -o fs=zroot/var/audit\;setuid=off\;exec=off \
	   -o fs=zroot/var/crash\;setuid=off\;exec=off \
	   -o fs=zroot/var/log\;setuid=off\;exec=off \
	   -o fs=zroot/var/mail\;atime=on \
	   -o fs=zroot/var/tmp\;setuid=off \
	   ${outfileroot} ${rootdir}

    # reguid since makefs creates images with a static guid
    mdid=$(mdconfig -a -f ${outfileroot} | grep -o '[[:digit:]]*')
    zpool import -t -R /tmp/plz-pb--zroot zroot plz-pb--zroot
    zpool reguid plz-pb--zroot
    zpool export plz-pb--zroot
    mdconfig -d -u ${mdid}

    local efidir
    efidir=${BUILDDIR}/efistage
    mkdir -p ${efidir}/efi/boot

    cp ${rootdir}/boot/loader.efi ${efidir}/efi/boot/bootx64.efi
    makefs -t msdos \
	 -o fat_type=32 -o sectors_per_cluster=1 -o volume_label=EFISYS \
	 -s 50m \
	 ${BUILDDIR}/boot.part ${efidir}

    mkimg -s gpt -p efi/esp:=${BUILDDIR}/boot.part \
	  -p freebsd-zfs:=${outfileroot} -o ${BUILDDIR}/${outfile}.img --capacity 21G
}

main "${@}"
