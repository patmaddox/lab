#!/bin/sh
set -eu
set -o pipefail

jjroot=$(jj root)

if [ ! -f bin/redo-c/redo ]; then
    mkdir -p bin/redo-c
    cd oss/redo-c
    ./bootstrap.sh
    cp redo-always redo-ifchange redo-ifcreate redo ${jjroot}/bin/redo-c/
fi
