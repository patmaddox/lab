#!/bin/sh
set -eu

main() {
    local freebsd_txz outfile distfiles mdid

    freebsd_txz=${1}; shift
    outfile=${1}; shift

    outfileroot=${BUILDDIR}/${outfile}.zfs
    rootdir=${BUILDDIR}/imgroot
    mkdir ${rootdir}
    rootdir=$(realpath ${rootdir})

    build::create-zpool
    build::extract
    build::config
    build::copy-freebsd-rel
    build::efi-partition
    build::export-zpool
    build::finalize-image
}

build::create-zpool() {
    truncate -s 20g ${outfileroot}
    mdid=$(mdconfig -a -f ${outfileroot} | grep -o '[[:digit:]]*')

    zpool create -m none -o autoexpand=on -t plz-pb--zroot -R ${rootdir} zroot /dev/md${mdid}
    zfs create -o mountpoint=none plz-pb--zroot/ROOT
    zfs create -o mountpoint=/ plz-pb--zroot/ROOT/default
    zfs create -o mountpoint=/home plz-pb--zroot/home
    zfs create -o mountpoint=/tmp -o exec=on -o setuid=off plz-pb--zroot/tmp
    zfs create -o mountpoint=/usr -o canmount=off plz-pb--zroot/usr
    zfs create -o setuid=off plz-pb--zroot/usr/ports
    zfs create plz-pb--zroot/usr/src
    zfs create plz-pb--zroot/usr/obj
    zfs create -o mountpoint=/var -o canmount=off plz-pb--zroot/var
    zfs create -o setuid=off -o exec=off plz-pb--zroot/var/audit
    zfs create -o setuid=off -o exec=off plz-pb--zroot/var/crash
    zfs create -o setuid=off -o exec=off plz-pb--zroot/var/log
    zfs create -o atime=on plz-pb--zroot/var/mail
    zfs create -o setuid=off plz-pb--zroot/var/tmp
    zpool set bootfs=plz-pb--zroot/ROOT/default plz-pb--zroot
}

build::extract() {
    local p
    for p in base kernel src; do
	tar -C ${rootdir} -xf ${freebsd_txz}/${p}.txz
    done

    tar -c -C ${PORTSDIR} . | tar -x -C ${rootdir}/usr/ports --gid 0 --uid 0
}

build::config() {
    tar -c -C ${DISTDIR} . | tar -x -C ${rootdir} --gid 0 --uid 0
}

build::copy-freebsd-rel() {
    mkdir -p ${rootdir}/opt/distfiles/freebsd-rel

    local rel cleanname
    for rel in ${FREEBSD_REL}; do
	cleanname=$(basename ${rel} | sed -e 's/^rel--//')
	mv ${rel} ${rootdir}/opt/distfiles/freebsd-rel/${cleanname}
    done
}

build::efi-partition() {
    local efidir
    efidir=${BUILDDIR}/efistage
    mkdir -p ${efidir}/efi/boot

    cp ${rootdir}/boot/loader.efi ${efidir}/efi/boot/bootx64.efi
    makefs -t msdos \
	   -o fat_type=32 -o sectors_per_cluster=1 -o volume_label=EFISYS \
	   -s 50m \
	   ${BUILDDIR}/boot.part ${efidir}
}

build::export-zpool() {
    zfs snapshot -r plz-pb--zroot@init
    zpool export plz-pb--zroot
    mdconfig -d -u ${mdid}
}

build::finalize-image() {
    mkimg -s gpt -p efi/esp:=${BUILDDIR}/boot.part \
	  -p freebsd-zfs:=${outfileroot} -o ${BUILDDIR}/${outfile}.img --capacity 21G
}

main "${@}"
