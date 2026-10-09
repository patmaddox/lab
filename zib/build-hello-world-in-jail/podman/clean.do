#!/bin/sh
set -eu
set -o pipefail

exec >&2

readonly name="hello-podman"

if ./podman.sh is_running; then
	echo "E: cannot clean hello-podman because it is still running"
	exit 1
fi

if [ -n "$(doas podman ps --noheading -a -f name=${name})" ]; then
	echo doas podman rm ${name}
	doas podman rm ${name}
fi

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

rm -f build_image.log
