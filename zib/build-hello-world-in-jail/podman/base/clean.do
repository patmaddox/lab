#!/bin/sh
set -eu
set -o pipefail

exec >&2

readonly name="freebsd-base:15.0"

if [ -n "$(doas buildah containers -n -f name=${name})" ]; then
	echo doas buildah rm ${name}
	doas buildah rm ${name}
fi

if [ -n "$(doas podman images -n ${name} 2>/dev/null)" ]; then
	echo doas podman rmi ${name}
	doas podman rmi ${name}
fi

if [ -n "$(doas buildah images -n ${name} 2>/dev/null)" ]; then
	echo doas buildah rmi ${name}
	doas buildah rmi ${name}
fi

rm -f build.log
