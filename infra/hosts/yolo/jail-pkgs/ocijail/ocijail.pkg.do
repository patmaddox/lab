#!/bin/sh
set -eu

# Build ocijail, podman's runtime, for yolo's jails, in place of
# FreeBSD's package of it. FreeBSD's, 0.6.1, leaks four mounts for each
# container a jail runs. This is upstream's main at ${commit}, which
# fixes the order ocijail unmounts in, with unmount-file-by-fsid.patch,
# which unmounts the nullfs file mounts that 15.1's kernel leaves
# unreachable by path. See README.org.

readonly commit=d7a2e71d1dea1c22559a97dbb873c523b4431407
readonly sha256=cb4f49263f7368520d32ca269ffe52ef77874f0455386d098a57f067422bc8fc
readonly url=https://github.com/dfr/ocijail/archive/${commit}.tar.gz

# 0.7.0.d<date of ${commit}>. The epoch, ,1, puts it above any version
# of FreeBSD's, which has none, so pkg installs it whichever is newer.
# Bump the part before the epoch with each change to the package.
readonly version="0.7.0.d20261016,1"

# The jails run FreeBSD 15, and the binary must too.
readonly major=15

redo-ifchange unmount-file-by-fsid.patch

if [ "$(uname -r | cut -d. -f1)" != ${major} ]; then
	echo "E: build ocijail on FreeBSD ${major}, which yolo's jails run" >&2
	exit 1
fi

workdir=$(mktemp -d)
trap "rm -rf ${workdir}" EXIT

fetch -qo ${workdir}/src.tar.gz ${url}
if [ "$(sha256 -q ${workdir}/src.tar.gz)" != ${sha256} ]; then
	echo "E: ${url} does not have the expected SHA256" >&2
	exit 1
fi
tar -xf ${workdir}/src.tar.gz -C ${workdir}
src=${workdir}/ocijail-${commit}
patch -s -d ${src} -p1 < unmount-file-by-fsid.patch

# Its dependencies are header-only, CLI11 and nlohmann's json, and come
# in its distfiles, so it needs no bazel.
mkdir ${workdir}/deps
unzip -q ${src}/distfiles/v2.3.2.zip -d ${workdir}/deps
unzip -q ${src}/distfiles/include.zip -d ${workdir}/deps

stagedir=${workdir}/stage
mkdir -p ${stagedir}/usr/local/bin
c++ -std=c++20 -O2 -I${src} -I${workdir}/deps/CLI11-2.3.2/include \
    -I${workdir}/deps/include ${src}/ocijail/*.cpp -lm \
    -o ${stagedir}/usr/local/bin/ocijail

flatsize=$(stat -f%z ${stagedir}/usr/local/bin/ocijail)

cat > ${workdir}/+MANIFEST <<EOM
name: ocijail
version: "${version}"
origin: sysutils/ocijail
comment: "OCI-compatible runtime for jails, patched for yolo's jails"
maintainer: pat@patmaddox.com
prefix: /usr/local
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/infra/hosts/yolo/jail-pkgs/ocijail
abi: "FreeBSD:${major}:amd64"
licenselogic: single
licenses: [BSD2CLAUSE]
flatsize: ${flatsize}
desc: <<EOD
ocijail from upstream's main at ${commit},
with a fix for the nullfs file mounts it leaks in a jail. See
infra/hosts/yolo/jail-pkgs/ocijail/README.org.
EOD
files: {
  /usr/local/bin/ocijail: "-"
}
EOM

pkg create -M ${workdir}/+MANIFEST -r ${stagedir} -o ${workdir}
mv ${workdir}/ocijail-${version}.pkg ${3}
