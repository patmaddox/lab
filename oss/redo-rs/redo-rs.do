#!/bin/sh
set -eu
set -o pipefail

curdir=$(pwd)
cd default.jj
cargo build --release
cd ${curdir}
cp default.jj/target/release/redo ${3}
