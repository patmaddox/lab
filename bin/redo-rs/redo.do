#!/bin/sh
set -eu
set -o pipefail

srcdir=../../oss/redo-rs
${REDO}-ifchange ${srcdir}/build
cp ${srcdir}/default.jj/target/release/redo ${3}
