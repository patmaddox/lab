#!/bin/sh
set -eu
set -o pipefail

redo-ifchange clone

cd default.jj
make
./bin/redo test
