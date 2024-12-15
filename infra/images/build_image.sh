#!/bin/sh
set -eu

main() {
    parse_env_vars
    local mdid

    build::create-zpool
    build::extract
#    build::config
#    build::copy-freebsd-rel
#    build::efi-partition
    build::export-zpool
#    build::finalize-image
}

build::create-zpool() {
    test ! -e ${OUTS_IMG}
    truncate -s 5g ${OUTS_IMG}
    mdid=$(mdconfig -a -f ${OUTS_IMG} | grep -o '[[:digit:]]*')

    zpool create -m / -o autoexpand=on -t plz-tmp--zroot -R ${ROOTDIR} zroot /dev/md${mdid}
    zfs create -o mountpoint=/tmp -o exec=on -o setuid=off plz-tmp--zroot/tmp
    zfs create -o mountpoint=/var -o canmount=off plz-tmp--zroot/var
    zfs create -o setuid=off -o exec=off plz-tmp--zroot/var/audit
    zfs create -o setuid=off -o exec=off plz-tmp--zroot/var/crash
    zfs create -o setuid=off -o exec=off plz-tmp--zroot/var/log
    zfs create -o atime=on plz-tmp--zroot/var/mail
    zfs create -o setuid=off plz-tmp--zroot/var/tmp
    zpool set bootfs=plz-tmp--zroot plz-tmp--zroot
}

build::extract() {
    local p
    for p in ${SRCS_BASE_TXZ} ${SRCS_KERNEL_TXZ}; do
	tar -C ${ROOTDIR} -xf ${p}
    done

    local distdir
    distdir=$(dirname ${SRCS_METALOG})
    tar -C ${distdir} -c @METALOG | tar -C ${ROOTDIR} -x
}

build::config() {
    tar -c -C ${DISTDIR} . | tar -x -C ${rootdir} --gid 0 --uid 0

    mkdir -p ${rootdir}/opt/etc
    local f
    for f in ${PORTSFILES}; do
	cp ${f} ${rootdir}/opt/etc/
    done
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

    cp ${ROOTDIR}/boot/loader.efi ${efidir}/efi/boot/bootx64.efi
    makefs -t msdos \
	   -o fat_type=32 -o sectors_per_cluster=1 -o volume_label=EFISYS \
	   -s 50m \
	   ${BUILDDIR}/boot.part ${efidir}
}

build::export-zpool() {
    zfs snapshot -r plz-tmp--zroot@init
    zpool export plz-tmp--zroot
    mdconfig -d -u ${mdid}
}

build::finalize-image() {
    mkimg -s gpt -p efi/esp:=${BUILDDIR}/boot.part \
	  -p freebsd-zfs:=${outfileroot} -o ${BUILDDIR}/${outfile}.img --capacity 21G
}

parse_env_vars() {
    : realpath ${SRCS_BASE_TXZ}
    : realpath ${SRCS_KERNEL_TXZ}
    : realpath ${SRCS_METALOG}
    : ${TMPDIR}

    BUILDDIR=${TMPDIR}/_build
    ROOTDIR=${BUILDDIR}/root
}

main "${@}"
