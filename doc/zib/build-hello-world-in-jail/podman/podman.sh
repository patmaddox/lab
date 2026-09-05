#!/bin/sh
set -eu
set -o pipefail

base="freebsd-base:15.0"
name="hello-podman"

# layer 1: expense, so cache
if [ -z "$(buildah images -q ${base})" ]; then
	buildah from --name ${base} scratch
	broot=$(buildah mount ${base})
	mkdir -p ${broot}/usr/share
	cp -Rp /usr/share/keys ${broot}/usr/share
	pkg -r ${broot} -C pkgbase-150.conf install \
	    -r FreeBSD-base \
	    -y FreeBSD-set-base-jail
	buildah unmount ${base}
	buildah commit ${base} ${base}
	buildah rm ${base}
fi

# layer 2: stuff to keep the container up. cheap so rebuild
buildah from --name ${name} ${base}
buildah copy --chmod 0700 ${name} container-init /sbin/container-init
buildah config --cmd /sbin/container-init ${name}
buildah commit ${name} ${name}
buildah rm ${name}
