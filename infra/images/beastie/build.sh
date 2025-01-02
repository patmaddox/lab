#!/bin/sh
set -eu
set -o pipefail

BENAME="beastie-14.2-RELEASE-2025-01-02_1"
BE="zroot/ROOT/${BENAME}"
BEROOT="/tmp/be_mount-${BENAME}"

CURDIR=$(pwd)
DOWNLOAD_ROOT="https://download.freebsd.org/releases/amd64/14.2-RELEASE/"

USERS="root patmaddox"
GROUPS="wheel patmaddox video webcamd"
SYNC_PW=$(realpath ../../../src/sync-pw/sync-pw)

DOAS=doas

main() {
    cmd=${1}; shift
    logfile=${1}; shift

    ${cmd}
    touch ${logfile}
}

makebe() {
    ${DOAS} zfs create -o mountpoint=none ${BE}
}

mountbe() {
    bectl list | awk 'BEGIN { status = 1 }; $1 == "${BENAME}" && $3 == "${BEROOT}" { status = 0 }; END { exit status }' || ${DOAS} bectl mount ${BE} ${BEROOT}
}

freebsd() {
    for f in base kernel; do
	fetch -o - ${DOWNLOAD_ROOT}/${f}.txz | tar -C ${BEROOT} -x
    done
    zfs snapshot ${BE}@freebsd
}

main "${@}"
