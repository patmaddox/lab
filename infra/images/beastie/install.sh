#!/bin/sh
set -eu
set -o pipefail

BENAME="beastie-14.2-RELEASE-2025-01-01"
BE="zroot/ROOT/${BENAME}"
BEROOT="/tmp/be_mount-${BENAME}"

CURDIR=$(pwd)
DOWNLOAD_ROOT="https://download.freebsd.org/releases/amd64/14.2-RELEASE/"

USERS="root patmaddox"
GROUPS="wheel patmaddox video webcamd"
SYNC_PW=$(realpath ../../../src/sync-pw/sync-pw)

main() {
    create_be
    mount_be
    install_freebsd
    install_freebsd_config
    install_packages
    install_packages_config
    install_data
    umount_be
}

create_be() {
    if zfs list ${BE} > /dev/null 2>&1; then
	error "boot environment ${BENAME} already exists"
    fi

    zfs create -o mountpoint=none ${BE}
    zfs snapshot ${BE}@empty
}

mount_be() {
    bectl mount ${BENAME} ${BEROOT} > /dev/null
}

umount_be() {
    bectl umount ${BENAME}
}

install_freebsd() {
    for f in base kernel; do
	fetch -o - ${DOWNLOAD_ROOT}/${f}.txz | tar -C ${BEROOT} -x
    done
    zfs snapshot ${BE}@freebsd
}

install_freebsd_config() {
    tar -C dist -c @base.mtree | tar -C ${BEROOT} -x
    zfs snapshot ${BE}@freebsd_config
}

install_packages() {
    PKG_CACHEDIR=/var/cache/pkg pkg -r ${BEROOT} install -r FreeBSD -y $(cat beastie.ports)
    zfs snapshot ${BE}@packages
}

install_packages_config() {
    tar -C dist -c @packages.mtree | tar -C ${BEROOT} -x
    zfs snapshot ${BE}@packages_config
}

install_data() {
    tar -C / -c @${CURDIR}/dist/data.mtree | tar -C ${BEROOT} -x
    ${SYNC_PW} /etc ${BEROOT}/etc u ${USERS}
    ${SYNC_PW} /etc ${BEROOT}/etc g ${GROUPS}
    zfs snapshot ${BE}@data
}

error() {
    echo "E: ${@}" 1>&2
    exit 1
}

main "${@}"
