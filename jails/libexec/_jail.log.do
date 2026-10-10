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

readonly jailsdir=$(realpath $(dirname $(realpath ${0}))/..)

redo-ifchange instance.conf ${jailsdir}/libexec/jail.subr
. instance.conf
. ${jailsdir}/libexec/jail.subr
readonly PKGBASE_CONF="${jailsdir}/share/pkgbase.conf"
readonly PKGBASE_PACKAGES="${pkgbase_sets:-FreeBSD-set-base-jail} ${pkgbase_extras:-}"
readonly PACKAGES="${packages:-}"

# global vars created by functions
# rootdir

main() {
	verify_zroot
	create_jail_root
	install_freebsd
	_jail_start
	create_groups
	create_users
	# clone_repo
	# bootstrap
	# ready
}

verify_zroot() {
	if ! zfs list ${zroot}/instances >/dev/null 2>&1; then
		echo "E: missing ${zroot}/instances" >&2
		exit 1
	fi
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

	local keys="/usr/share/keys/pkgbase-$(freebsd-version -u | cut -d. -f1)"

	doas mkdir -p ${rootdir}${keys}
	tar -C ${keys} -cf - . | doas tar -C ${rootdir}${keys} -xf -
	doas pkg -r ${rootdir} -C ${PKGBASE_CONF} install -r FreeBSD-base -y ${PKGBASE_PACKAGES}

	if [ ! -f ${rootdir}/etc/resolv.conf ]; then
		echo "nameserver 8.8.8.8" | doas tee ${rootdir}/etc/resolv.conf > /dev/null
	fi

	if [ -n "${PACKAGES}" ]; then
		doas pkg -c ${rootdir} install -y ${PACKAGES}
	fi
}

create_groups() {
	local _name _gid
	while IFS=: read -r _name _gid; do
		if [ -n "${_name}" ] && [ -n "${_gid}" ]; then
			add_group ${_name} ${_gid}
		fi
	done <<EOF
${groups:-}
EOF
}

create_users() {
	local _username _uid _gid _groups
	while IFS=: read -r _username _uid _gid _groups; do
		if [ -n "${_username}" ] && [ -n "${_uid}" ] && [ -n "${_gid}" ]; then
			   add_group "${_username}" "${_gid}"
			   add_user "${_username}" "${_uid}"

			   if [ -n "${_groups}" ]; then
				   local group
				   while IFS=, read -r group; do
					   echo "adding ${_username} to ${group}"
					   _jail_exec pw group mod -m ${_username} -n ${group}
				   done <<EOF
${_groups}
EOF
			   fi
		fi
	done <<EOF
${users:-}
EOF
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
	:
}

bootstrap() {
	# ...
	# install additional packages etc?
	:
}

# no "${@}" since it's called by redo and we don't want the params,
# i.e. this is not an interactive command that takes args
main | tee -a ${redoout} >&2
