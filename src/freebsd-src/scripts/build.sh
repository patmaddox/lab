#!/bin/sh
# https://patmaddox.com/file?name=infra/pdt/lib/pdt-src&ci=06fcb33c1bc90bd5

set -eu

main() {
    curdir=$(pwd)
    mkdir ${BUILDDIR}/rel

    tar -C ${SRCDIR} -s '|^|usr/src/|' -cf ${BUILDDIR}/rel/src.txz --uid 0 --gid 0 .
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

    cp ${SRCDIR}/release/scripts/make-manifest.sh ${BUILDDIR}/rel
    cd ${BUILDDIR}/rel
    sh make-manifest.sh *.txz > MANIFEST
    touch done.manifest
    cd ${curdir}

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
