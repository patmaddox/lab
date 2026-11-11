#!/bin/sh
set -eu

# Build the package of yolo-jail.
# Install on yolo, as root, with: pkg add yolo-jail.pkg

name="yolo-jail"
version="0.0.0"

# Each line: mode, source, and path in the package.
files="
0555 yolo-jail-template /usr/local/sbin/yolo-jail-template
0555 yolo-jail-clone /usr/local/libexec/yolo-jail-clone
0555 yolo-git-init /usr/local/sbin/yolo-git-init
0555 yolo-jail-git /usr/local/libexec/yolo-jail-git
0444 templates/coding-agent.conf /usr/local/share/${name}/templates/coding-agent.conf
0444 templates/coding-agent.files/usr/local/etc/gitconfig /usr/local/share/${name}/templates/coding-agent.files/usr/local/etc/gitconfig
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
version: ${version}
origin: local/${name}
comment: Build and clone the ZFS templates of yolo's jails
maintainer: pat@patmaddox.com
prefix: /
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/infra/hosts/yolo/src/yolo-jail
flatsize: ${flatsize}
desc: <<EOD
Build the ZFS templates that yolo's jails are cloned from, and clone
them. See infra/hosts/yolo/src/yolo-jail/README.org.
EOD
files: {
$(echo "${files}" | awk 'NF { print "  " $3 ": \"-\"" }')
}
EOM

pkg create -M "${manifest}" -r "${stagedir}" -o "$(dirname "$3")"
mv "$(dirname "$3")/${name}-${version}.pkg" "$3"
