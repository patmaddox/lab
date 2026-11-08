#!/bin/sh
set -eu

build=../../scripts/pkgbase-be.sh
redo-ifchange ${build} yolo.conf
exec ${build} yolo.conf ${3}
