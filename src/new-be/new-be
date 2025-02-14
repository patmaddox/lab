#!/bin/sh
set -eu
set -o pipefail

DOAS="/usr/local/bin/doas"
TOOLS_SYNC_PW=$(realpath ../../../src/sync-pw/sync-pw)

USERS=""
GROUPS=""
PORTFILE=""
BASEFILES=""
BASE_MTREE=""
DATA_MTREE=""
PACKAGES_MTREE=""

main() {
    parse_args "${@}"

    validate_users
    validate_groups
    validate_files

    create_be
    install_base
    install_packages
    sync_pw
    umount_be
}

parse_args() {
    local opt ifs

    while getopts u:g:B:D:p:P: opt; do
	case ${opt} in
	    u)
		USERS=${OPTARG}
		;;
	    g)
		GROUPS=${OPTARG}
		;;
	    B)
		BASE_MTREE=$(realpath ${OPTARG})
		;;
	    D)
		DATA_MTREE=$(realpath ${OPTARG})
		;;
	    p)
		PORTFILE=$(realpath ${OPTARG})
		;;
	    P)
		PACKAGES_MTREE=$(realpath ${OPTARG})
		;;
	    "?")
		exit 1
		;;
	esac
    done

    shift $((OPTIND - 1))

    NAME=${1}; shift
    TMPROOT=/tmp/new-be-${NAME}
    BASEFILES="${@}"
}

validate_users() {
    local IFS
    IFS=","

    for u in ${USERS}; do
	pw usershow ${u} > /dev/null
    done
}

validate_groups() {
    local IFS
    IFS=","

    for g in ${GROUPS}; do
	pw groupshow ${g} > /dev/null
    done
}

validate_files() {
    for f in ${BASEFILES}; do
	realpath ${f} > /dev/null
    done
}

create_be() {
    ${DOAS} zfs create -o canmount=noauto -o mountpoint=none zroot/ROOT/${NAME}
    ${DOAS} bectl mount ${NAME} ${TMPROOT}
}

umount_be() {
    ${DOAS} bectl umount ${NAME}
}

install_base() {
    for f in ${BASEFILES}; do
	${DOAS} tar -C ${TMPROOT} -xf ${f}
    done

    if [ -n "${BASE_MTREE}" ]; then
	tar -C $(dirname ${BASE_MTREE}) -c @${BASE_MTREE} | ${DOAS} tar -C ${TMPROOT} -x
    fi

    if [ -n "${DATA_MTREE}" ]; then
	${DOAS} tar -C / -c @${DATA_MTREE} | ${DOAS} tar -C ${TMPROOT} -x
    fi
}

install_packages() {
    if [ -n "${PORTFILE}" ]; then
	local PKG_CACHE
	PKG_CACHE=/var/cache/pkg
	${DOAS} mkdir -p ${TMPROOT}${PKG_CACHE}
	${DOAS} mount_nullfs ${PKG_CACHE} ${TMPROOT}${PKG_CACHE}

	local origins
	origins=$(paste -s -d ' ' ${PORTFILE})
	${DOAS} pkg -c ${TMPROOT} install -y ${origins}

	${DOAS} umount ${TMPROOT}${PKG_CACHE}
    fi

    if [ -n "${PACKAGES_MTREE}" ]; then
	tar -C $(dirname ${PACKAGES_MTREE}) -c @${PACKAGES_MTREE} | ${DOAS} tar -C ${TMPROOT} -x
    fi
}

sync_pw() {
    local IFS
    IFS=","

    for u in ${USERS}; do
	${DOAS} ${TOOLS_SYNC_PW} /etc ${TMPROOT}/etc u ${u}
    done

    for g in ${GROUPS}; do
	${DOAS} ${TOOLS_SYNC_PW} /etc ${TMPROOT}/etc g ${g}
    done
}

main "${@}"
