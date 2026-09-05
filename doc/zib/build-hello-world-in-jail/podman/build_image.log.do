#!/bin/sh
set -eu
set -o pipefail

readonly _redo_outfile=${3}
readonly image="hello-podman"

_redo_log() {
	tee -a ${_redo_outfile} >&2
}

build_image() {
	doas podman build -t ${image} --network host --dns 8.8.8.8 hello-podman
	echo "DONE build_image"
}

redo-ifchange base/build.log hello-podman/Containerfile
build_image | _redo_log
