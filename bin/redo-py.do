#!/bin/sh
set -eu
set -o pipefail

redo_bin=../oss/redo-py/default.jj/bin/redo
redo-ifchange ${redo_bin}
ln -sf ${redo_bin} ${3}
