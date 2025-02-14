#!/bin/sh
set -eu
set -o pipefail

main() {
    parse_args "${@}"

    cmd::${CMD}
}

parse_args() {
    local tree

    CMD=${1}; shift
    tree=${1}; shift

    SRC_ROOT=$(realpath ${tree})
    OPT_BOOTSTRAP=0
    MAKE_FLAGS=""

    case ${CMD} in
	bootstrap)
	    OPT_BOOTSTRAP=1
	    CMD=build
	    ;;
	build)
	    MAKE_FLAGS="-DWORLDFAST -DKERNFAST"
	    ;;
	release|clean-release)
	    SRC_ROOT=$(realpath ${SRC_ROOT}/release)
	    ;;
	clean)
	    ;;
	*)
	    echo "E: unknown command ${CMD}" 1>&2
	    exit 1
	    ;;
    esac

    __MAKE_CONF=/dev/null
    SRCCONF=$(realpath src.conf)
    OBJROOT=$(pwd)/_build/$(basename ${tree} .jj)/
    CCACHE_CONFIGPATH=$(realpath ccache.conf)
}

cmd::build() {
    _make obj
    if [ ${OPT_BOOTSTRAP} -eq 1 ]; then _make cleanworld; fi
    _make buildworld buildkernel
}

cmd::release() {
    _make obj
    _make -DNOPORTS packagesystem
}

cmd::clean() {
    _make obj
    _make cleanworld
}

cmd::clean-release() {
    _make obj
    _make clean
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
	       -DNO_ROOT ${MAKE_FLAGS} ${@}
}

main "${@}"
