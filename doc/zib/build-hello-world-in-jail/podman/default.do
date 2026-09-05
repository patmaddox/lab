#!/bin/sh
set -eu
set -o pipefail

readonly _redo_outfile=${3}
readonly base="freebsd-base:15.0"
readonly image="hello-podman"

_redo_log() {
	tee -a ${_redo_outfile} >&2
}

# A build that dies partway leaves its working container behind, and
# buildah refuses to reuse the name.
_rm_container() {
	if [ -n "$(doas buildah containers -n -f name=${1})" ]; then
		doas buildah rm ${1}
	fi
}

build_image() {
	_rm_container ${image}
	doas buildah from --name ${image} ${base}
	doas buildah copy --chmod 0700 ${image} container-init /sbin/container-init
	doas buildah config --cmd /sbin/container-init ${image}
	doas buildah commit ${image} ${image}
	doas buildah rm ${image}
	echo "DONE build_image"
}

case ${1} in
build_image.log)
	redo-ifchange base/build.log
	build_image | _redo_log
	;;
*)
	echo "E: unknown target ${1}" >&2
	exit 1
	;;
esac
