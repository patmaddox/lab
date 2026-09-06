#!/bin/sh
set -eu
set -o pipefail

# redo stuff
readonly target=${1}
readonly redoout=${3}

redo-ifchange workspace.subr
. workspace.subr

readonly pkgbase_conf="pkgbase-150.conf"
readonly pkgbase_sets="FreeBSD-set-minimal-jail"

# global vars created by functions
# rootdir

main() {
	create_jail_root
	install_freebsd
	# start jail
	clone_repo
	bootstrap
	# ready
}

create_jail_root() {
	if ! zfs list ${wroot} >/dev/null 2>&1; then
		doas zfs create ${wroot}
	fi
	rootdir=$(zfs get -H -o value mountpoint ${wroot})
}

install_freebsd() {
	if [ ! -d ${rootdir} ]; then
		echo "E: ${rootdir} is missing (${wroot})" >&2
		exit 1
	fi

	doas mkdir -p ${rootdir}/usr/share/keys/pkgbase-15
	tar -C /usr/share/keys/pkgbase-15 -cf - . | doas tar -C ${rootdir}/usr/share/keys/pkgbase-15 -xf -
	doas pkg -r ${rootdir} -C ${pkgbase_conf} install -r FreeBSD-base -y ${pkgbase_sets}
}

clone_repo() {
	# clone to tmp if needed
	# move it into place
}

bootstrap() {
	# ...
	# install additional packages etc?
}

# no "${@}" since it's called by redo and we don't want the params,
# i.e. this is not an interactive command that takes args
main | tee -a ${redoout} >&2
