#!/bin/sh
set -eu
set -o pipefail

KERNCONF=${KERNCONF:-GENERIC}
export KERNCONF

main() {
    parse_args "${@}"
    ensure_not_dirty

    _make obj
    OBJDIR=$(cmd::objdir)
    cmd::${CMD}
}

parse_args() {
    local tree

    CMD=${1}; shift
    CONFIG=${1}; shift

    . $(realpath ${CONFIG})

    SRC_ROOT=$(realpath ${TREE})
    REPO_ROOT=${SRC_ROOT}

    case ${CMD} in
	release|clean-release|objdir-release)
	    SRC_ROOT=$(realpath ${SRC_ROOT}/release)
	    ;;
	build|clean|objdir|ls-files)
	    ;;
	*)
	    echo "E: unknown command ${CMD}" 1>&2
	    exit 1
	    ;;
    esac

    __MAKE_CONF=/dev/null
    SRCCONF=$(realpath src.conf)
    OBJROOT=$(pwd)/_build/$(basename ${CONFIG} .conf)/
    CCACHE_CONFIGPATH=$(realpath ccache.conf)
}

ensure_not_dirty() {
    set +o pipefail
    if ! jj -R ${REPO_ROOT} status --quiet | grep -q '^Working copy .* (empty) (no description set)'; then
	echo "E: refusing to build in a dirty tree"
	exit 1
    fi
    set -o pipefail
}

cmd::build() {
    _make buildworld buildkernel
}

cmd::release() {
    # packagesystem does not pick up changes after buildworld, so need
    # to clean it first
    _make clean
    _make -DNOPORTS packagesystem
}

cmd::clean() {
    _make cleanworld
}

cmd::clean-release() {
    _make clean
}

cmd::objdir() {
    _make -V .OBJDIR
}

cmd::objdir-release() {
    # OBJDIR is already set via cmd::objdir in main
    echo ${OBJDIR}
}

cmd::ls-files() {
    jj -R ${SRC_ROOT} file list
}

_make() {
    __MAKE_CONF=${__MAKE_CONF} \
	       SRCCONF=${SRCCONF} \
	       OBJROOT=${OBJROOT} \
	       CCACHE_CONFIGPATH=${CCACHE_CONFIGPATH} \
	       make \
	       -C ${SRC_ROOT} \
	       -s \
	       -j$(sysctl -n hw.ncpu) \
	       -DNO_ROOT ${@}
}

main "${@}"
