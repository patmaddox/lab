#!/bin/sh
set -eu
set -o pipefail

exec >&2

if ./podman.sh is_running; then
	echo "E: cannot clean hello-podman because it is still running"
	exit 1
fi

for i in freebsd-base:15.0 hello-podman; do
	if [ -n "$(doas podman ps --noheading -a -f name=${i})" ]; then
		echo doas podman rm ${i}
		doas podman rm ${i}
	fi

	if [ -n "$(doas buildah containers -n -f name=${i})" ]; then
		echo doas buildah rm ${i}
		doas buildah rm ${i}
	fi

	if [ -n "$(doas podman images -n ${i} 2>/dev/null)" ]; then
		echo doas podman rmi ${i}
		doas podman rmi ${i}
	fi

	if [ -n "$(doas buildah images -n ${i} 2>/dev/null)" ]; then
		echo doas buildah rmi ${i}
		doas buildah rmi ${i}
	fi
done

rm -f tmp/build_base.log tmp/build_image.log
