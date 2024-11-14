#!/bin/sh
# https://patmaddox.com/file?name=infra/pdt/lib/pdt-src&ci=06fcb33c1bc90bd5

set -eu

main() {
    local srcdir commit

    srcdir="${1}"; shift
    commit="${1}"; shift

    jj -R ${srcdir} edit ${commit} --ignore-immutable

    export DISTDIR=${TMP_DIR}/rel-${commit}

    do_make="doas make -s -C ${srcdir} -j $(/sbin/sysctl -n hw.ncpu) TZ=UTC SRCCONF=/dev/null __MAKE_CONF=/dev/null"

    ${do_make} buildworld
    ${do_make} buildkernel
    ${do_make} DISTDIR=${DISTDIR} distributeworld
    ${do_make} DISTDIR=${DISTDIR} distributekernel
}

main "${@}"
