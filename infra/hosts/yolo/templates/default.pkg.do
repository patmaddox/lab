#!/bin/sh
set -eu

# Build package yolo-<name> from <name>/: its conf, <name>.conf, which
# sets comment, packages, and users; pkg-plist, which lists the files
# and symlinks it installs; and dist/, which holds them in the shape of
# the jail's root. It depends on the conf's packages, and makes the
# conf's users when it is installed or upgraded.
#
# Its version is the time it was built, so each build is an upgrade.
# redo rebuilds it only when the conf, the plist, or a file the plist
# lists changes, so the version moves only with the package.

readonly pkgdir=${2}
readonly name=yolo-${pkgdir}
readonly conf=${pkgdir}/${pkgdir}.conf
readonly plist=${pkgdir}/pkg-plist
readonly dist=${pkgdir}/dist
version=$(date -u +%Y.%m.%d.%H%M%S)
readonly version

# The path of each file and symlink in the plist: its lines that are
# not keywords, and those with attributes, such as @(root,wheel,0600).
paths() {
	sed -n -e 's/^@config //p' -e 's/^@[a-z]*([^)]*) //p' -e '/^[^@]/p' ${plist}
}

# The files, that is. A symlink's target is no file of the package's.
redo-ifchange ${conf} ${plist} $(paths | while read -r path; do
	[ -L ${dist}${path} ] || echo ${dist}${path}
done)

# The conf sets these.
comment=""
packages=""
users=""
. ./${conf}

metadir=$(mktemp -d)
trap "rm -rf ${metadir}" EXIT

# users: one user:uid per line. Each gets a group of the same name and
# id, and unrestricted doas. pkg runs this on install and on upgrade,
# so it adds only what is missing.
if [ -n "$(echo ${users})" ]; then
	{
		echo 'set -eu'
		echo 'doas_conf=/usr/local/etc/doas.conf'
		echo "${users}" | while IFS=: read -r user uid; do
			[ -n "${user}" ] || continue
			cat <<EOS
pw groupshow -n ${user} >/dev/null 2>&1 || pw groupadd -n ${user} -g ${uid}
pw usershow -n ${user} >/dev/null 2>&1 ||
    pw useradd -n ${user} -u ${uid} -g ${user} -m -s /bin/sh
grep -qx 'permit nopass keepenv ${user}' \${doas_conf} 2>/dev/null ||
    echo 'permit nopass keepenv ${user}' >> \${doas_conf}
EOS
		done
	} > ${metadir}/+POST_INSTALL
fi

# pkg resolves a dependency by its name, from whichever repository has
# it, so the origin and version here are only recorded.
deps=$(for p in ${packages}; do
	echo "  ${p}: { origin: \"unknown/${p}\", version: \"0\" }"
done)

cat > ${metadir}/+MANIFEST <<EOM
name: ${name}
version: "${version}"
origin: local/${name}
comment: "${comment}"
maintainer: pat@patmaddox.com
prefix: /
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/infra/hosts/yolo/templates
desc: <<EOD
${comment}. See infra/hosts/yolo/README.org.
EOD
deps: {
${deps}
}
EOM

pkg create -m ${metadir} -p ${plist} -r ${dist} -o ${metadir}
mv ${metadir}/${name}-${version}.pkg ${3}
