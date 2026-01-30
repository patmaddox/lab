#!/bin/sh
set -eu
set -o pipefail

exec >/dev/null 2>&1

if [ -d default.jj ]; then
    cd default.jj
    gmake clean 2>/dev/null
fi
