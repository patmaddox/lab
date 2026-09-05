#!/bin/sh
set -eu
set -o pipefail

readonly _redo_outfile=${3}
readonly name="freebsd-base:15.0"

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

build() {
	_rm_container ${name}
	doas buildah from --name ${name} scratch
	readonly broot=$(doas buildah mount ${name})
	doas mkdir -p ${broot}/usr/share
	doas cp -Rp /usr/share/keys ${broot}/usr/share
	doas pkg -r ${broot} -C ../../pkgbase-150.conf install \
	    -r FreeBSD-base \
	    -y FreeBSD-set-minimal-jail
	doas buildah unmount ${name}
	doas buildah commit ${name} ${name}
	doas buildah rm ${name}
	echo "DONE build_base"
}

case ${1} in
build.log) build | _redo_log ;;
*)
	echo "E: unknown target ${1}" >&2
	exit 1
	;;
esac
