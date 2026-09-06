#!/bin/sh
set -eu
set -o pipefail

# redo stuff
readonly target=${1}; shift
readonly _target_i_dont_get_yet=${1}; shift
readonly redoout=${1}; shift

if [ "${#}" -gt 0 ]; then
	echo "E: extra args to redo: ${@}" >&2
	exit 1
fi

readonly HALROOT=${HALROOT:-$(realpath $(dirname $(realpath ${0}))/..)}

redo-ifchange hal.instance.conf ${HALROOT}/libexec/hal.subr
. hal.instance.conf
. ${HALROOT}/libexec/hal.subr
readonly PKGBASE_CONF="${HALROOT}/share/pkgbase-150.conf"
readonly PKGBASE_SETS=${pkgbase_sets:-FreeBSD-set-minimal-jail}

# global vars created by functions
# rootdir

main() {
	verify_hal
	create_jail_root
	install_freebsd
	_jail_start
	create_users
	clone_repo
	bootstrap
	# ready
}

verify_hal() {
	local d
	for d in instances jail.conf.d; do
		if ! zfs list ${zroot}/${d} >/dev/null 2>&1; then
			echo "E: missing ${zroot}/${d}" >&2
			exit 1
		fi
	done
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
	doas pkg -r ${rootdir} -C ${PKGBASE_CONF} install -r FreeBSD-base -y ${PKGBASE_SETS}
}

create_users() {
	local _username _uid _gid
	while IFS=: read -r _username _uid _gid _rest; do
		if validate_userline "${_username}" "${_uid}" "${_gid}" "${_rest}"; then
			add_group ${_username} ${_gid}
			add_user ${_username} ${_uid}
		fi
	done <<EOF
${users}
EOF
}

validate_userline() {
	local line username uid gid rest
	username=${1}; shift
	uid=${1}; shift
	gid=${1}; shift
	rest=${1}; shift

	# this is how we filter empty userlines
	if [ -z "${username}${uid}${gid}${rest}" ]; then
		return 1
	fi

	if [ -z "${username}" ]; then
		echo "E: invalid userline" >&2
		exit 1
	fi
	if [ -z "${uid}" ]; then
		echo "E: invalid userline" >&2
		exit 1
	fi
	if [ -z "${gid}" ]; then
		echo "E: invalid userline" >&2
		exit 1
	fi
	if [ -n "${rest}" ]; then
		echo "E: invalid userline" >&2
		exit 1
	fi
}

add_group() {
	local group gid
	group=${1}; shift
	gid=${1}; shift

	if ! _jail_exec pw group show ${group} >/dev/null 2>&1; then
		echo "making new group: ${group} with gid: ${gid}"
		_jail_exec pw group add -n ${group} -g ${gid}
	fi
}

add_user() {
	local username uid
	username=${1}; shift
	uid=${1}; shift

	if ! _jail_exec pw user show ${username} >/dev/null 2>&1; then
		echo "making new user: ${username} with uid: ${uid}"
		_jail_exec pw user add -n ${username} -u ${uid} -g ${username} -m -s sh
	fi
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
