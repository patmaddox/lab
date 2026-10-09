#!/bin/sh
set -eu
set -o pipefail

readonly workspace=$(basename $(jj workspace root) .jj)
echo lab-${workspace}-hello-world-in-jail
