#!/bin/sh
#
# Shared freebsd-src builder
#
# Symlink this as default.do in each target directory.
# Redo passes the target name as $2 (e.g. buildworld, pkgbase).
# Each target dir has a config file with rev and kernel settings.
set -eu
set -o pipefail

exec >&2

SRC_ROOT=$(dirname $(dirname $(realpath $0)))
config=$(basename $(pwd))
target=$2

. ./config

case "${target}" in
    help)
	cat >&2 <<EOF
Targets:
  buildworld   Build world
  buildkernel  Build kernel (depends on buildworld)
  pkgbase      Build packages (depends on buildworld, buildkernel)
  vm-image     Build VM image (depends on pkgbase)

Config: ${config}
  rev:    ${rev}
  kernel: ${kernel}
EOF
	exit 0
	;;
    rev.stamp)
	redo-always
	jj -R ${SRC_ROOT}/default.jj log -r "${rev}" -T 'commit_id' --no-graph | redo-stamp
	exit 0
	;;
    buildworld)
	srcs=rev.stamp
	;;
    buildkernel)
	srcs=buildworld
	;;
    pkgbase)
	srcs="buildworld buildkernel"
	;;
    vm-image)
	export VM_IMAGE_CONFIG=${SRC_ROOT}/share/vm-nodbg32.conf
	srcs="pkgbase ${SRC_ROOT}/share/vm-nodbg32.conf"
	;;
    *)
	echo "E: unknown target ${target}" >&2
	echo "Run 'redo help' for usage." >&2
	exit 1
esac

export SRC_ROOT
export CCACHE_CONFIGPATH=${SRC_ROOT}/ccache.conf
export JJ_ROOT=$(realpath ${SRC_ROOT}/default.jj)
export KERNCONF=${kernel}
export SRCCONF=$(realpath ${SRC_ROOT}/src.conf)

# redo-rs sets MAKEFLAGS in a way that produces
#     make: illegal argument to -j -- must be positive integer!
unset MAKEFLAGS

outdir=${SRC_ROOT}/_build/${config}
mkdir -p ${outdir}

redo-ifchange ${srcs} ${SRC_ROOT}/share/build.sh
${SRC_ROOT}/share/build.sh ${target} ${config} ${rev} ${outdir} | tee ${3}
