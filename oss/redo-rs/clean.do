#!/bin/sh
set -eu
set -o pipefail

exec >/dev/null 2>&1

rm -f redo-rs

if [ -d default.jj ]; then
    cd default.jj
    cargo clean
fi
