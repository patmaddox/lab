#!/bin/sh
# https://patmaddox.com/file?name=infra/pdt/lib/pdt-src&ci=06fcb33c1bc90bd5

set -eu

main() {
    check_env_vars

    local targets
    parse_args "${@}"

    cd ${TMP_DIR}
    mkdir -p ${OUTS_PKGBASE_DIR} ${OUTS_REL_DIR} ${DISTDIR}

    local t
    for t in ${targets}; do
	validate_target ${t}
    done

    for t in ${targets}; do
	make::${t}
    done
}

validate_target() {
    local target
    target=${1}; shift

    case "${target}" in
	all|buildworld|buildkernel|distributeworld|distributekernel|packageworld|packagekernel|pkgbase|release)
            ;;
	*)
	    echo "E: unknown target ${target}" 1>&2
	    exit 1
	    ;;
    esac
}

make::all() {
    local t
    for t in buildworld buildkernel distributeworld distributekernel packageworld packagekernel release pkgbase; do
	make::${t}
    done
}

make::buildworld() {
    make::src buildworld
}

make::buildkernel() {
    make::src buildkernel
}

make::distributeworld() {
    make::src distributeworld DISTDIR=${DISTDIR}
}

make::distributekernel() {
    make::src distributekernel DISTDIR=${DISTDIR}
}

make::packageworld() {
    make::src packageworld DISTDIR=${DISTDIR}
}

make::packagekernel() {
    make::src packagekernel DISTDIR=${DISTDIR}
}

make::src() {
    local target vars
    target=${1}; shift
    vars="${@}"

    ${make} \
	${vars} \
	SRCCONF=${SRCS_SRCCONF} \
	__MAKE_CONF=/dev/null \
	${target}
    touch done.${target}
}

make::pkgbase() {
    local tmppkgbase
    tmppkgbase=${TMP_DIR}/tmp-pkgbase

    # packages doesn't like DISTDIR for some reason
    ${make} \
	REPODIR=${tmppkgbase} \
	packages

    cp -Rp ${tmppkgbase}/ ${OUTS_PKGBASE_DIR}/
    ${TOOLS_DOAS} chflags -R noschg ${tmppkgbase}
    ${TOOLS_DOAS} rm -rf ${tmppkgbase}
    touch done.packages
}

make::release() {
    cp ${SRCS_FREEBSD}/release/scripts/make-manifest.sh ${DISTDIR}/

    local tarballs
    tarballs="base.txz kernel.txz tests.txz"
    cd ${DISTDIR}
    sh make-manifest.sh ${tarballs} > ${OUTS_REL_DIR}/MANIFEST
    cp ${tarballs} ${OUTS_REL_DIR}/
    cd ${TMP_DIR}

    ${TOOLS_DOAS} chflags -R noschg ${DISTDIR}
    ${TOOLS_DOAS} rm -rf ${DISTDIR}
    touch done.release
}


check_env_vars() {
    : ${KERNCONF}

    # check input paths
    SRCS_FREEBSD=$(realpath ${SRCS_FREEBSD})
    SRCS_SRCCONF=$(realpath ${SRCS_SRCCONF})
    TMP_DIR=$(realpath ${TMP_DIR})

    # output / build dirs are generated
    DISTDIR=${TMP_DIR}/dist
    OUTS_PKGBASE_DIR=${TMP_DIR}/${OUTS_PKGBASE_DIR}
    OUTS_REL_DIR=${TMP_DIR}/${OUTS_REL_DIR}

    local ccache_configpath
    ccache_configpath=$(realpath ${SRCS_CCACHE_CONF})

    TOOLS_DOAS=${TOOLS_DOAS:-}

    make="${TOOLS_DOAS} env -i \
			CCACHE_CONFIGPATH=${ccache_configpath} \
			KERNCONF=${KERNCONF} \
    			PATH=${PATH} \
			TZ=UTC \
			make -s \
			-C ${SRCS_FREEBSD} \
			-j $(sysctl -n hw.ncpu)"
}

parse_args() {
    targets="${@}"
}

main "${@}"
