#!/bin/sh
set -eu
set -o pipefail

${REDO}-ifchange $(jj -R default.jj file list)
curdir=$(pwd)
cd default.jj
cargo build --release
cd ${curdir}
