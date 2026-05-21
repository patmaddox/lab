#!/bin/sh
set -eu
set -o pipefail

buildroot=/var/tmp/freebsd-src

main() {
    local cmd
    cmd=${1}; shift

    case "${cmd}" in
	buildworld|buildkernel|pkgbase|vm-image)
 	    : ${CCACHE_CONFIGPATH}
 	    : ${JJ_ROOT}
 	    : ${KERNCONF}
 	    : ${SRCCONF}

	    local config rev src pkgbase sha
	    parse_build_args "${@}"
	    checkout_code

	    ${cmd}
	    ;;
	*)
	    echo "Unknown command: ${cmd}" >&2
	    exit 1
	    ;;
    esac
}

parse_build_args() {
    config=${1}; shift
    rev=${1}; shift

    src=${buildroot}/${config}
    objroot=${src}/obj/  # trailing / required by src.sys.obj.mk
    pkgbase=${buildroot}/pkgbase/${config}

    sha=$(jj -R ${JJ_ROOT} log -r "${rev}" -T 'commit_id' --no-graph)
}

checkout_code() {
    test -d ${src}/.git || git clone --no-checkout ${JJ_ROOT} ${src}
    git -C ${src} remote update
    git -C ${src} checkout -f ${sha}
    git -C ${src} clean -fdx
}

buildworld() {
    _make buildworld
}

buildkernel() {
    _make buildkernel
}

pkgbase() {
    mkdir -p ${pkgbase}
    _make REPODIR=${pkgbase} packages
}

vm-image() {
    _make_release clean -DWITH_VMIMAGES

    local objtop pkg_abi pkgbase_conf_dir
    objtop=$(OBJROOT=${objroot} make -C ${src} -V OBJTOP)
    pkg_abi=$(pkg -o ABI_FILE=${objtop}/worldstage/usr/bin/uname config ABI)
    pkgbase_conf_dir=${objtop}/release/pkgbase-repo-dir
    mkdir -p ${pkgbase_conf_dir}
    cat > ${pkgbase_conf_dir}/FreeBSD-base.conf <<EOF
FreeBSD-base: { url: "file://${pkgbase}/${pkg_abi}/latest", enabled: yes}
EOF
    _make_release PKGBASE_REPO_DIR=${pkgbase} VM_IMAGE_CONFIG=$(realpath ${VM_IMAGE_CONFIG}) VMFORMATS=raw -DWITH_VMIMAGES vm-image
}

_make() {
    __MAKE_CONF=/dev/null \
	CCACHE_BASEDIR='${SRCTOP}' \
	CCACHE_CONFIGPATH=$(realpath ${CCACHE_CONFIGPATH}) \
	KERNCONF=${KERNCONF} \
	OBJROOT=${objroot} \
	SRCCONF=$(realpath ${SRCCONF}) \
	nice -n 20 \
	make -C ${src} \
	-s \
	-j$(sysctl -n hw.ncpu) \
	-DNO_ROOT \
	${@}
}

_make_release() {
    __MAKE_CONF=/dev/null \
	CCACHE_BASEDIR='${SRCTOP}' \
	CCACHE_CONFIGPATH=$(realpath ${CCACHE_CONFIGPATH}) \
	KERNCONF=${KERNCONF} \
	OBJROOT=${objroot} \
	SRCCONF=$(realpath ${SRCCONF}) \
	nice -n 20 \
	make -C ${src}/release \
	-s \
	-j$(sysctl -n hw.ncpu) \
	-DNO_ROOT \
	-DNOPORTS \
	-DNOSRC \
	${@}
}

main "${@}"
