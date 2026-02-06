#!/bin/sh
set -eu
set -o pipefail

main() {
    local cmd
    cmd=${1}; shift

    case "${cmd}" in
	buildworld|buildkernel|pkgbase|vm-image)
 	    : ${CCACHE_CONFIGPATH}
 	    : ${GIT_MAIN}
 	    : ${KERNCONF}
 	    : ${SRCCONF}

	    local config jjdir outdir src obj sha branch
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
    jjdir=${1}; shift
    outdir=${1}; shift

    ensure_not_dirty

    src=${outdir}/src
    obj=${outdir}/obj

    sha=$(jj -R ${jjdir} log -r '@-' -T 'commit_id' --no-graph)
    branch=$(jj -R ${jjdir} log -r '::@ & bookmarks()' -n 1 -T 'self.local_bookmarks()' --no-graph | sed 's/\*$//')
}

ensure_not_dirty() {
    set +o pipefail
    if ! jj -R ${jjdir} status --quiet | grep -q '^Working copy .* (empty) (no description set)'; then
	echo "E: refusing to build in a dirty tree: ${jjdir}" >&2
	exit 1
    fi
    set -o pipefail
}

checkout_code() {
    mkdir -p ${obj}

    test -d ${src}/.git || git clone --no-checkout ${GIT_MAIN} ${src}
    git -C ${src} remote update
    git -C ${src} fetch origin ${sha}
    git -C ${src} clean -fdx
    git -C ${src} checkout ${branch}
    git -C ${src} reset --hard ${sha}
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
    _make_release PKGBASE_REPO_DIR=$(realpath ${repodir}) VM_IMAGE_CONFIG=$(realpath ${jjdir}/../tools/vm-nodbg32.conf) VMFORMATS=raw -DWITH_VMIMAGES vm-image
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
