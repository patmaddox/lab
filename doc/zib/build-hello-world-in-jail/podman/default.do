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

build_base() {
	_rm_container ${base}
	doas buildah from --name ${base} scratch
	readonly broot=$(doas buildah mount ${base})
	doas mkdir -p ${broot}/usr/share
	doas cp -Rp /usr/share/keys ${broot}/usr/share
	doas pkg -r ${broot} -C ../pkgbase-150.conf install \
	    -r FreeBSD-base \
	    -y FreeBSD-set-base-jail
	doas buildah unmount ${base}
	doas buildah commit ${base} ${base}
	doas buildah rm ${base}
	echo "DONE build_base"
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
tmp/build_base.log) build_base | _redo_log ;;
tmp/build_image.log)
	redo-ifchange tmp/build_base.log
	build_image | _redo_log
	;;
*)
	echo "E: unknown target ${1}" >&2
	exit 1
	;;
esac
