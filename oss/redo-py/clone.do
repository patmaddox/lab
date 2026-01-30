#!/bin/sh
set -eu
set -o pipefail

if [ ! -d default.jj ]; then
    jj git clone --colocate https://github.com/apenwarr/redo.git default.jj
fi
