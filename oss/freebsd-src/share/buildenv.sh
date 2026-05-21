#!/bin/sh
#
# Enter a build environment shell for working on individual programs.
#
# Run from a target directory (e.g. targets/default).
# Ensures buildworld is up to date, then drops into a shell in the
# source tree with the right compiler, paths, and object directory.
set -eu
set -o pipefail

SRC_ROOT=$(dirname $(dirname $(realpath $0)))
config=$(basename $(pwd))

. ./config
. ${SRC_ROOT}/share/build-common.sh

export CCACHE_CONFIGPATH=${SRC_ROOT}/ccache.conf
export KERNCONF=${kernel}
export SRCCONF=$(realpath ${SRC_ROOT}/src.conf)

# redo-rs sets MAKEFLAGS in a way that produces
#     make: illegal argument to -j -- must be positive integer!
unset MAKEFLAGS

objroot=$(build_objroot "${config}")

case "${rev}" in
    *@) workspace=${rev%@} ;;
    *)
	echo "buildenv requires a workspace rev (ending in @), got: ${rev}" >&2
	exit 1
	;;
esac
srcdir=${SRC_ROOT}/${workspace}.jj

if [ ! -d ${srcdir} ]; then
    echo "workspace directory not found: ${srcdir}" >&2
    exit 1
fi

build_make -C ${srcdir} buildenv
