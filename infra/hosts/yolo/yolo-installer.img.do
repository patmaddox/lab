#!/bin/sh
set -eu

build=../../scripts/bsdinstall-stick.sh
redo-ifchange ${build} stick.conf
exec ${build} stick.conf ${3}
