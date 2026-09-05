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
	doas mkdir -p ${broot}/usr/local/etc/pkg/repos
	echo "FreeBSD-base: { enabled: yes }" | doas tee ${broot}/usr/local/etc/pkg/repos/FreeBSD.conf >/dev/null
	doas install -m 0700 container-init ${broot}/sbin/container-init
	doas buildah config --cmd /sbin/container-init ${name}
	doas buildah unmount ${name}
	doas buildah commit ${name} ${name}
	doas buildah rm ${name}
	echo "DONE build_base"
}

redo-ifchange container-init ../../pkgbase-150.conf
build | _redo_log
