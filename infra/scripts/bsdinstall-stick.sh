#!/bin/sh
#
# bsdinstall-stick.sh <config> <outfile>
#
# Build an installer stick image for a host: the release memstick,
# unchanged, with a UFS slice added after it that holds the host's boot
# environment stream and the files in bsdinstall-stick/. Boot the
# stick, choose Shell, and run:
#
#   mount -r /dev/ufs/installer /media
#   sh /media/install.sh <disk>
#
# <config> is a sh(1) file in the host directory that sets:
#
#   release          the FreeBSD release, e.g. 15.1
#   memstick_sha256  the SHA256 of its memstick.img.xz, as listed in
#                    the release's CHECKSUM.SHA256 file
#   stream           the boot environment stream, relative to <config>
#   be               the name to import it as
#   swap_size        the swap partition's size, or 0 for none
set -eu
set -o pipefail

exec >&2

# The stream holds secrets, such as the host's private keys.
umask 077

usage() {
    echo "Usage: bsdinstall-stick.sh <config> <outfile>"
}

tooldir=$(dirname $(realpath ${0}))/bsdinstall-stick
config=$(realpath ${1:?$(usage)})
outfile=$(cd $(dirname ${2:?$(usage)}) && pwd)/$(basename ${2})
cd $(dirname ${config})

# Defaults, which the config may override.
arch=amd64
label=installer

. ${config}

: ${release:?} ${memstick_sha256:?} ${stream:?} ${be:?} ${swap_size:?}

memstick=FreeBSD-${release}-RELEASE-${arch}-memstick.img.xz
url=https://download.freebsd.org/releases/${arch}/${arch}/ISO-IMAGES/${release}/${memstick}

# The memstick is kept here between builds.
cache=${XDG_CACHE_HOME:-${HOME}/.cache}/bsdinstall-stick

workdir=""
md=""
slice=""
mnt=""
mounted=""

redo-ifchange ${stream} ${tooldir}/install.sh ${tooldir}/installerconfig

main() {
    trap 'exit 1' INT TERM
    trap cleanup EXIT

    workdir=$(mktemp -d -t bsdinstall-stick)
    mnt=${workdir}/mnt
    mkdir ${mnt}
    cat > ${workdir}/install.conf <<CONF
be=${be}
stream=$(basename ${stream})
swap_size=${swap_size}
CONF
    files="${stream} ${tooldir}/install.sh ${tooldir}/installerconfig
	${workdir}/install.conf"

    fetch_memstick
    xz -dc ${cache}/${memstick} > ${outfile}
    add_slice
    copy_files
}

fetch_memstick() {
    mkdir -p ${cache}
    memstick_ok && return 0

    fetch -o ${cache}/${memstick}.part ${url}
    mv ${cache}/${memstick}.part ${cache}/${memstick}
    memstick_ok || fail "${memstick} does not match memstick_sha256"
}

memstick_ok() {
    [ -e ${cache}/${memstick} ] &&
	[ "$(sha256 -q ${cache}/${memstick})" = "${memstick_sha256}" ]
}

# The memstick uses MBR, so the slice goes in as a third MBR slice, in
# space added past the end of the image. Size it to the files, plus a
# tenth and 64 MB for UFS to work in.
add_slice() {
    local size

    size=$(stat -f %z ${files} |
	awk '{ s += $1 } END { printf "%d", s * 1.1 / 1048576 + 64 }')
    truncate -s +${size}m ${outfile}

    md=$(doas mdconfig -a -t vnode -f ${outfile})
    slice=$(doas gpart add -t freebsd ${md} | cut -d' ' -f1)
    doas newfs -L ${label} /dev/${slice} > /dev/null
}

copy_files() {
    local f

    doas mount /dev/${slice} ${mnt}
    mounted=yes

    doas install -m 0600 ${files} ${mnt}
    for f in ${files}; do
	doas cmp -s ${f} ${mnt}/$(basename ${f}) ||
	    fail "${f} did not copy to the slice"
    done

    doas umount ${mnt}
    mounted=""
    doas mdconfig -d -u ${md}
    md=""
}

fail() {
    echo "bsdinstall-stick: $*" >&2
    exit 1
}

cleanup() {
    [ -n "${mounted}" ] && doas umount ${mnt} || true
    [ -n "${md}" ] && doas mdconfig -d -u ${md} || true
    [ -n "${workdir}" ] && rm -rf ${workdir} || true
}

main
