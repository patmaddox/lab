#!/bin/sh
set -eu
set -o pipefail

main() {
    local cmd
    cmd=${1}; shift

    case "${cmd}" in
	buildworld|buildkernel|pkgbase|vm-image)
 	    : ${CCACHE_CONFIGPATH}
 	    : ${JJ_ROOT}
 	    : ${KERNCONF}
 	    : ${SRCCONF}

	    local config rev outdir src obj sha
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
    outdir=${1}; shift

    src=${outdir}/src
    obj=${outdir}/obj

    sha=$(jj -R ${JJ_ROOT} log -r "${rev}" -T 'commit_id' --no-graph)
}

checkout_code() {
    mkdir -p ${obj}

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
    local repodir
    repodir=${outdir}/pkgbase
    mkdir -p ${repodir}
    _make REPODIR=$(realpath ${repodir}) packages
}

vm-image() {
    _make_release clean -DWITH_VMIMAGES

    local repodir objtop pkg_abi pkgbase_conf_dir
    objtop=$(make -C ${src} -V OBJTOP OBJROOT=$(realpath ${obj})/)
    pkg_abi=$(pkg -o ABI_FILE=${objtop}/worldstage/usr/bin/uname config ABI)
    pkgbase_conf_dir=${objtop}/release/pkgbase-repo-dir
    mkdir -p ${pkgbase_conf_dir}
    repodir=${outdir}/pkgbase
    cat > ${pkgbase_conf_dir}/FreeBSD-base.conf <<EOF
FreeBSD-base: { url: "file://$(realpath ${repodir})/${pkg_abi}/latest", enabled: yes}
EOF
    _make_release PKGBASE_REPO_DIR=$(realpath ${repodir}) VM_IMAGE_CONFIG=$(realpath ${VM_IMAGE_CONFIG}) VMFORMATS=raw -DWITH_VMIMAGES vm-image
}

_make() {
    __MAKE_CONF=/dev/null \
	CCACHE_CONFIGPATH=$(realpath ${CCACHE_CONFIGPATH}) \
	KERNCONF=${KERNCONF} \
	OBJROOT=$(realpath ${obj})/ \
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
	CCACHE_CONFIGPATH=$(realpath ${CCACHE_CONFIGPATH}) \
	KERNCONF=${KERNCONF} \
	OBJROOT=$(realpath ${obj})/ \
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
