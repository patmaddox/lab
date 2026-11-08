#!/bin/sh
set -eu

build=../../scripts/pkgbase-be.sh
redo-ifchange ${build} rowdy.conf
exec ${build} rowdy.conf ${3}
