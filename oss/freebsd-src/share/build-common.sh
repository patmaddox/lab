#!/bin/sh
#
# Shared definitions for FreeBSD build scripts.
# Source this file; do not execute it directly.

buildroot=/var/tmp/freebsd-src

# Compute objroot for a given config name.
# Trailing / required by src.sys.obj.mk.
build_objroot() {
    echo "${buildroot}/${1}/obj/"
}

# Run make with the standard FreeBSD build environment variables.
# Caller provides -C dir and any additional flags/targets.
# Requires: objroot, CCACHE_CONFIGPATH, KERNCONF, SRCCONF
build_make() {
    __MAKE_CONF=/dev/null \
	CCACHE_BASEDIR='${SRCTOP}' \
	CCACHE_CONFIGPATH=$(realpath ${CCACHE_CONFIGPATH}) \
	KERNCONF=${KERNCONF} \
	OBJROOT=${objroot} \
	SRCCONF=$(realpath ${SRCCONF}) \
	WITH_META_MODE=YES \
	make "${@}"
}
