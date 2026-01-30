#!/bin/sh
set -eu
set -o pipefail

if [ ! -d default.jj ]; then
    jj git clone --colocate https://github.com/zombiezen/redo-rs.git default.jj
fi
