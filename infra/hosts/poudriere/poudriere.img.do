#!/bin/sh
set -eu
set -o pipefail

exec >&2

ABI=FreeBSD:16:amd64

redo-ifchange \
    dist.mtree \
    $(jj file list dist) \
    scripts/build.sh \
    repos/FreeBSD.conf

ABI=${ABI} ./scripts/build.sh ${3}
