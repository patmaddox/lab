#!/bin/sh
set -eu
set -o pipefail

redo-ifchange build

cd default.jj
cargo test
