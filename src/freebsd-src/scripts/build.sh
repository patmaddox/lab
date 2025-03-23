#!/bin/sh
set -eu
set -o pipefail

KERNCONF=${KERNCONF:-GENERIC}
export KERNCONF

main() {
    parse_args "${@}"

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
    OPT_BOOTSTRAP=0
    MAKE_FLAGS=""

    case ${CMD} in
	bootstrap)
	    OPT_BOOTSTRAP=1
	    CMD=build
	    ;;
	release|clean-release|objdir-release)
	    SRC_ROOT=$(realpath ${SRC_ROOT}/release)
	    ;;
	build|clean|objdir)
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

cmd::build() {
    local build_stamp
    build_stamp=${OBJDIR}/tmp/build.done

    if [ ! -f ${build_stamp} ]; then
	OPT_BOOTSTRAP=1
    fi

    if [ ${OPT_BOOTSTRAP} -eq 1 ]; then
	_make cleanworld
    else
	MAKE_FLAGS="-DWORLDFAST -DKERNFAST"
    fi

    _make buildworld buildkernel
    touch ${build_stamp}
}

cmd::release() {
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
