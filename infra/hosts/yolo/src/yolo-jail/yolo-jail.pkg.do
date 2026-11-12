#!/bin/sh
set -eu

# Build the package of yolo-jail.
# yolo's BE carries it, and just install-pkg installs a newer one
# from the repository on yolo.

name="yolo-jail"
# Its version is the time it was built. redo rebuilds it only when what
# it holds changes, so the version moves only then, and pkg on yolo
# upgrades to it from the repository.
version=$(date -u +%Y.%m.%d.%H%M%S)

# Each line: mode, source, and path in the package.
files="
0555 yolo-jail-init /usr/local/sbin/yolo-jail-init
0555 yolo-jail-create /usr/local/libexec/yolo-jail-create
0555 yolo-jail-create-mountpoints /usr/local/libexec/yolo-jail-create-mountpoints
0555 yolo-jail-upgrade /usr/local/sbin/yolo-jail-upgrade
0555 yolo-git-init /usr/local/sbin/yolo-git-init
0555 yolo-jail-git /usr/local/libexec/yolo-jail-git
0555 yolo-jail-repo /usr/local/libexec/yolo-jail-repo
0555 yolo-jail-data /usr/local/libexec/yolo-jail-data
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
comment: Create and upgrade yolo's jails
maintainer: pat@patmaddox.com
prefix: /
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/infra/hosts/yolo/src/yolo-jail
flatsize: ${flatsize}
# pkg resolves a dependency by its name, so its version is only
# recorded. yolo-jail-create needs the repository that yolo-pkg-init,
# from yolo-pkg, makes.
deps: {
  yolo-pkg: { origin: local/yolo-pkg, version: "0" }
}
desc: <<EOD
Create yolo's jails from their templates' packages, and upgrade
them. See infra/hosts/yolo/src/yolo-jail/README.org.
EOD
files: {
$(echo "${files}" | awk 'NF { print "  " $3 ": \"-\"" }')
}
EOM

pkg create -M "${manifest}" -r "${stagedir}" -o "$(dirname "$3")"
mv "$(dirname "$3")/${name}-${version}.pkg" "$3"
