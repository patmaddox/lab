#!/bin/sh
set -eu
set -o pipefail

: ${CCACHE_CONFIGPATH}
: ${GIT_MAIN}
: ${KERNCONF}
: ${SRCCONF}

main() {
    local cmd
    cmd=${1}; shift

    case "${cmd}" in
	buildworld|buildkernel|pkgbase)
	    ${cmd} "${@}"
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
    stampfile=${1}; shift

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
    git -C ${src} checkout ${branch}
    git -C ${src} reset --hard ${sha}
}

buildworld() {
    local config jjdir outdir stampfile src obj sha branch
    parse_build_args "${@}"
    checkout_code
    _make buildworld
    touch ${stampfile}
}

buildkernel() {
    local config jjdir outdir stampfile src obj sha branch
    parse_build_args "${@}"
    checkout_code
    _make buildkernel
    touch ${stampfile}
}

pkgbase() {
    local config jjdir outdir stampfile src obj sha branch
    parse_build_args "${@}"
    checkout_code
    local repodir
    repodir=${outdir}/pkgbase
    mkdir -p ${repodir}
    _make REPODIR=$(realpath ${repodir}) packages
    touch ${stampfile}
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

main "${@}"
