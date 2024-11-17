#!/bin/sh
# https://patmaddox.com/file?name=infra/pdt/lib/pdt-src&ci=06fcb33c1bc90bd5

set -eu

main() {
    mkdir ${BUILDDIR}/rel
    tar -C ${SRCDIR} -cf ${BUILDDIR}/rel/src.txz .
    touch ${BUILDDIR}/done.src

    local t
    for t in buildworld buildkernel distributeworld distributekernel packageworld packagekernel; do
	make -s \
	     -C ${SRCDIR} \
	     -j $(sysctl -n hw.ncpu) \
	     DISTDIR=${BUILDDIR}/rel \
	     KERNCONF=${KERNCONF} \
	     OBJTOP=${BUILDDIR}/obj \
	     SRCCONF=${SRCCONF} \
	     TZ=UTC \
	     __MAKE_CONF=/dev/null \
	     ${t}

	touch ${BUILDDIR}/done.${t}
    done

    # some of the other vars (DISTDIR?) cause it to not find create-kernel-packages
    make -s \
	 -C ${SRCDIR} \
	 -j $(sysctl -n hw.ncpu) \
	 OBJTOP=${BUILDDIR}/obj \
	 REPODIR=${BUILDDIR}/pkgbase \
	 TZ=UTC \
	 packages

    touch ${BUILDDIR}/done.packages
}

main "${@}"
