#!/bin/sh
set -eu
set -o pipefail

readonly outfile=${3}
readonly rootdir=/tmp/jails/jello-world

build_jail() {
	mkdir -p ${rootdir}
	doas mkdir -p ${rootdir}/usr/share
	doas cp -Rp /usr/share/keys ${rootdir}/usr/share
	doas pkg -r ${rootdir} -C ../pkgbase-150.conf install \
	    -r FreeBSD-base \
	    -y FreeBSD-set-base-jail | tee -a ${outfile} >&2
	echo "nameserver 8.8.8.8" | doas tee ${rootdir}/etc/resolv.conf > /dev/null
	echo "done building" | tee -a ${outfile} >&2
}

case ${1} in
tmp/build_jail.log) build_jail ;;
*)
	echo "E: unknown target ${1}" >&2
	exit 1
	;;
esac
