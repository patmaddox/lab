#!/bin/sh
set -eu

# Build the package of yolo's package repository: its config, and
# yolo-pkg-init, which makes it. just pkg-init adds it to a yolo that
# lacks it, and after that just install-pkg upgrades it from the
# repository on yolo, with yolo's other packages.

name="yolo-pkg"
# Its version is the time it was built. redo rebuilds it only when what
# it holds changes, so the version moves only then, and pkg on yolo
# upgrades to it from the repository.
version=$(date -u +%Y.%m.%d.%H%M%S)

# Each line: mode, source, and path in the package.
files="
0555 yolo-pkg-init /usr/local/sbin/yolo-pkg-init
0644 yolo.conf /usr/local/etc/pkg/repos/yolo.conf
"

redo-ifchange $(echo "${files}" | awk 'NF { print $2 }')

stagedir=$(mktemp -d)
trap "rm -rf ${stagedir}" EXIT

echo "${files}" | while read -r mode src dst; do
	[ -n "${src}" ] || continue
	mkdir -p "${stagedir}$(dirname ${dst})"
	install -m ${mode} ${src} "${stagedir}${dst}"
done

flatsize=$(find "${stagedir}" -type f -exec stat -f%z {} + | awk '{s+=$1} END {print s}')

manifest="${stagedir}/+MANIFEST"
cat > "${manifest}" <<EOM
name: ${name}
version: "${version}"
origin: local/${name}
comment: yolo's package repository
maintainer: pat@patmaddox.com
prefix: /
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/infra/hosts/yolo/src/yolo-pkg
flatsize: ${flatsize}
desc: <<EOD
The config of yolo's package repository, /pkg/yolo, and yolo-pkg-init,
which makes it. See infra/hosts/yolo/src/yolo-pkg/README.org.
EOD
files: {
$(echo "${files}" | awk 'NF { print "  " $3 ": \"-\"" }')
}
EOM

pkg create -M "${manifest}" -r "${stagedir}" -o "$(dirname "$3")"
mv "$(dirname "$3")/${name}-${version}.pkg" "$3"
