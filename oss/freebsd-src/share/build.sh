#!/bin/sh
set -eu
set -o pipefail

. "$(dirname "$(realpath "$0")")/build-common.sh"

main() {
    renice -n 20 -p $$ > /dev/null

    local cmd
    cmd=${1}; shift

    case "${cmd}" in
	buildworld|buildkernel|pkgbase|vm_image)
 	    : ${CCACHE_CONFIGPATH}
 	    : ${JJ_ROOT}
 	    : ${KERNCONF}
 	    : ${SRCCONF}

	    local config sha src pkgbase
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
    sha=${1}; shift

    src=${buildroot}/${config}
    objroot=$(build_objroot "${config}")
    pkgbase=${buildroot}/pkgbase/${config}
}

checkout_code() {
    if [ ! -d ${src}/.git ]; then
	git clone --no-checkout ${JJ_ROOT} ${src}
    fi
    git -C ${src} fetch origin ${sha}
    git -C ${src} checkout -f ${sha}
}

buildworld() {
    _build buildworld
}

buildkernel() {
    _build buildkernel
}

pkgbase() {
    mkdir -p ${pkgbase}
    _build REPODIR=${pkgbase} packages
}

vm_image() {
    _build_release clean -DWITH_VMIMAGES

    local objtop pkg_abi pkgbase_conf_dir
    objtop=$(OBJROOT=${objroot} make -C ${src} -V OBJTOP)
    pkg_abi=$(pkg -o ABI_FILE=${objtop}/worldstage/usr/bin/uname config ABI)
    pkgbase_conf_dir=${objtop}/release/pkgbase-repo-dir
    mkdir -p ${pkgbase_conf_dir}
    cat > ${pkgbase_conf_dir}/FreeBSD-base.conf <<EOF
FreeBSD-base: { url: "file://${pkgbase}/${pkg_abi}/latest", enabled: yes}
EOF
    _build_release PKGBASE_REPO_DIR=${pkgbase} VM_IMAGE_CONFIG=$(realpath ${VM_IMAGE_CONFIG}) VMFORMATS=raw -DWITH_VMIMAGES vm-image
}

_build() {
    build_make -C ${src} -s -j$(sysctl -n hw.ncpu) -DNO_ROOT "${@}"
}

_build_release() {
    build_make -C ${src}/release -s -j$(sysctl -n hw.ncpu) -DNO_ROOT -DNOPORTS -DNOSRC "${@}"
}

main "${@}"
