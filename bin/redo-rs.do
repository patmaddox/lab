#!/bin/sh
set -eu
set -o pipefail

bin=../oss/redo-rs/redo-rs

redo-ifchange ${bin}
cp ${bin} ${3}
