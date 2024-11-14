#!/bin/sh
# https://patmaddox.com/file?name=infra/pdt/lib/pdt-src&ci=06fcb33c1bc90bd5

set -eu

main() {
    local srcdir
    srcdir="${1}"; shift
    DISTDIR=${BUILDDIR}/rel

    make="make -s -C ${srcdir} -j $(sysctl -n hw.ncpu) -D NO_ROOT TZ=UTC SRCCONF=/dev/null __MAKE_CONF=/dev/null DISTDIR=${DISTDIR} OBJTOP=${BUILDDIR}/obj"

    ${make} buildworld
    ${make} buildkernel
    ${make} distributeworld
    ${make} distributekernel
    ${make} packageworld
    ${make} packagekernel
}

main "${@}"
