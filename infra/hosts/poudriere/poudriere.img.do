#!/bin/sh
set -eu
set -o pipefail

exec >&2

config=current
redo-ifchange \
    dist.mtree \
    $(jj file list dist) \
    ../../../oss/freebsd-src/${config}.pkgbase

# not using export, because
# export FOO=$(cmd that fails)
# exits 0!
ABI=FreeBSD:16:amd64
PKGBASE_DIR=$(realpath ../../../oss/freebsd-src/_build/${config}/pkgbase/${ABI}/latest)
ABI=${ABI} PKGBASE_DIR=${PKGBASE_DIR} ./scripts/build.sh ${3}
