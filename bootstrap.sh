#!/bin/sh
set -eu
set -o pipefail

jjroot=$(jj root)

mkdir -p bin/redo-c
cd oss/redo-c
./bootstrap.sh
cp redo-always redo-ifchange redo-ifcreate redo ${jjroot}/bin/redo-c/
