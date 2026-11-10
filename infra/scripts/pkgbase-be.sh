#!/bin/sh
#
# pkgbase-be.sh <config> <outfile>
#
# Build a boot environment from upstream pkgbase and packages, and write
# it to <outfile> as a ZFS send stream for bectl import.
#
# <config> sets ${release}, e.g. 15.1. It picks the ABI, the pkgbase
# repository, and the keys that sign it.
#
# <config> is a sh(1) file in the host directory, which also holds:
#
#   dist/     files installed whole, listed with modes in dist/dist.mtree
#   secrets/  like dist/, but each file is an op inject template naming
#             the 1Password fields it holds; secrets/secrets.mtree
#
# SSH host keys (etc/ssh/ssh_host_*_key) and WireGuard keys
# (etc/wireguard/*.key) must match their public halves in dist, at
# <key>.pub and <name>.pub. Other secrets need only be non-empty.
#
# ${users} holds master.passwd(5) lines. Each replaces the image's line
# for that user, or is appended. Groups are added with pw(8). Either
# way, accounts the base system and packages create are left alone.
#
# The password field in ${users} is *, which refuses password logins.
# ${passwords} pairs a user with the 1Password reference of a password,
# and the image's pw(8) hashes it into that user's field.
set -eu
set -o pipefail

exec >&2

# The stream carries password hashes and private keys.
umask 077

usage() {
    echo "Usage: pkgbase-be.sh <config> <outfile>"
}

config=$(realpath ${1:?$(usage)})
outfile=$(cd $(dirname ${2:?$(usage)}) && pwd)/$(basename ${2})
cd $(dirname ${config})

# Defaults, which the config may override.
tmpfs_size=3g
pool_size=2g
# DNS servers pkg uses inside the image while it installs packages, if
# dist has no resolv.conf.
build_nameservers="8.8.8.8 8.8.4.4"
packages=""
groups=""
users=""
passwords=""
group_members=""
required_files=""
config_checks=""
arch=amd64

. ${config}

: ${name:?} ${release:?} ${timezone:?}
: ${base_packages:?}

# The release, e.g. 15.1, picks the ABI, the base repository, and the
# keys that sign it.
abi=FreeBSD:${release%%.*}:${arch}
base_url="pkg+https://pkg.FreeBSD.org/${abi}/base_release_${release#*.}"
base_keys=/usr/share/keys/pkgbase-${release%%.*}

# Downloaded packages and repository catalogs are kept here between
# builds, and shared by every host built for the same ABI.
pkg_cache=${pkg_cache:-/var/cache/pkgbase-be/${abi}}

pool=${name}--build
workdir=""
mounted=""
devmounted=""
cachemounted=""

redo-ifchange $(jj file list dist secrets)

main() {
    trap 'exit 1' INT TERM
    trap cleanup EXIT

    # Keep secrets and the pool image off disk, even if cleanup never runs.
    workdir=$(mktemp -d -t ${name})
    doas mount -t tmpfs \
	-o size=${tmpfs_size},mode=0700,uid=$(id -u),gid=$(id -g) \
	tmpfs ${workdir}
    mounted=yes
    secretdir=${workdir}/secrets
    usersfile=${workdir}/users
    passworddir=${workdir}/passwords
    lines "${users}" > ${usersfile}

    fetch_secrets
    verify_secrets
    create_pool
    mount_cache
    install_base

    # Everything outside /usr/local goes in before packages, along with
    # pkg's own config. The rest of /usr/local goes in after them, so no
    # package overwrites it.
    install_tree dist dist/dist.mtree --exclude ./usr/local
    install_tree dist dist/dist.mtree ./usr/local/etc/pkg
    install_tree ${secretdir} secrets/secrets.mtree
    install_ports
    umount_cache
    install_tree dist dist/dist.mtree ./usr/local

    add_accounts
    doas tzsetup -C ${rootdir} ${timezone}
    verify_image
    send_be
}

# Fetch first, so a missing secret fails the build before any doas.
fetch_secrets() {
    local path user ref

    secret_paths | while read -r path; do
	mkdir -p $(dirname ${secretdir}/${path})
	op inject -i secrets/${path} -o ${secretdir}/${path} \
	    < /dev/null > /dev/null
    done

    mkdir ${passworddir}
    lines "${passwords}" | while read -r user ref; do
	op read --no-newline ${ref} < /dev/null > ${passworddir}/${user}
    done
}

verify_secrets() {
    local path rel pub derived user hash rest

    # A private key must match the public half in dist, which clients and
    # peers already trust. Compare the key type and key, not the comment.
    secret_paths | while read -r path; do
	[ -s ${secretdir}/${path} ] || fail "${path} is empty"
	rel=${path#./}

	case ${path} in
	./etc/ssh/ssh_host_*_key)
	    pub=dist/${rel}.pub
	    [ -e ${pub} ] || fail "${path} has no ${pub}"
	    derived=$(ssh-keygen -y -f ${secretdir}/${path}) ||
		fail "${path} is not an ssh private key"
	    ;;
	./etc/wireguard/*.key)
	    pub=dist/${rel%.key}.pub
	    [ -e ${pub} ] || fail "${path} has no ${pub}"
	    derived=$(wg pubkey < ${secretdir}/${path}) ||
		fail "${path} is not a WireGuard private key"
	    ;;
	*)
	    continue
	    ;;
	esac

	[ "$(echo "${derived}" | cut -d' ' -f1,2)" = \
	    "$(cut -d' ' -f1,2 ${pub})" ] ||
	    fail "${path} does not match ${pub}"
    done

    # The repository holds no hashes, and never a plain password.
    while IFS=: read -r user hash rest; do
	[ "${hash}" = "*" ] || fail "${user} password field is not *"
    done < ${usersfile}

    # pw reads a password as one line.
    lines "${passwords}" | while read -r user ref; do
	[ -s ${passworddir}/${user} ] || fail "${user} password is empty"
	[ $(wc -l < ${passworddir}/${user}) -eq 0 ] ||
	    fail "${user} password is more than one line"
    done
}

create_pool() {
    rootdir=${workdir}/root
    mkdir ${rootdir}
    truncate -s ${pool_size} ${workdir}/pool.img

    doas zpool create -o ashift=12 -O compression=on -O mountpoint=none \
	-t ${pool} -R ${rootdir} zroot ${workdir}/pool.img
    doas zfs create -o mountpoint=none ${pool}/ROOT
    doas zfs create -o mountpoint=/ ${pool}/ROOT/default
}

# Base goes in with --rootdir: the image is empty, so pkg cannot chroot
# into it yet. pkg wants its repository config owned by root, and reads
# the signing keys relative to the image, so they go in first; the
# base packages install the same keys over them.
install_base() {
    local repos pkg_r

    repos=${workdir}/base-repos
    mkdir ${repos}
    cat > ${repos}/base.conf <<CONF
FreeBSD-base: {
  url: "${base_url}",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "${base_keys}",
  enabled: yes
}
CONF
    doas chown -R root:wheel ${repos}

    doas mkdir -p ${rootdir}$(dirname ${base_keys})
    doas cp -R ${base_keys} ${rootdir}${base_keys}

    pkg_r="doas pkg --rootdir ${rootdir} --repo-conf-dir ${repos} -o ASSUME_ALWAYS_YES=yes -o IGNORE_OSVERSION=yes -o ABI=${abi}"
    ${pkg_r} update
    ${pkg_r} install -r FreeBSD-base ${base_packages}
}

# Ports go in with --chroot, so their install scripts run against the
# image's own tools and accounts, and pkg uses the image's repository
# config and keys. pkg also needs DNS in there; if dist has no
# resolv.conf, because the host's comes from DHCP, use ${build_nameservers}
# until the packages are in.
install_ports() {
    local pkg_c ns temporary

    [ -n "$(echo ${packages})" ] || return 0

    temporary=""
    if ! doas test -e ${rootdir}/etc/resolv.conf; then
	for ns in ${build_nameservers}; do
	    echo "nameserver ${ns}"
	done | doas tee ${rootdir}/etc/resolv.conf > /dev/null
	temporary=yes
    fi

    mount_dev
    pkg_c="doas pkg --chroot ${rootdir} -o ASSUME_ALWAYS_YES=yes"
    ${pkg_c} update
    ${pkg_c} install -r FreeBSD-ports ${packages}
    # Only here does pkg see both repositories, so only here can it tell
    # which cached packages are out of date.
    ${pkg_c} clean -q
    umount_dev

    if [ -n "${temporary}" ]; then
	doas rm ${rootdir}/etc/resolv.conf
    fi
}

# install_tree <dir> <mtree> [path ...]: install the entries in <mtree>,
# or only those under the given paths.
install_tree() {
    local dir mtree

    dir=${1}
    mtree=${2}
    shift 2
    [ -e ${mtree} ] || return 0
    tar -c -C ${dir} -f - @$(realpath ${mtree}) |
	doas tar -x -C ${rootdir} -f - "$@"
}

add_accounts() {
    local etc group gid members user ref

    etc=${rootdir}/etc

    lines "${groups}" | while read -r group gid; do
	doas pw -R ${rootdir} groupadd ${group} -g ${gid}
    done

    doas cat ${etc}/master.passwd | awk -F: '
	NR == FNR { line[$1] = $0; order[++n] = $1; next }
	$1 in line { print line[$1]; done[$1] = 1; next }
	{ print }
	END {
	    for (i = 1; i <= n; i++)
		if (!(order[i] in done)) print line[order[i]]
	}' ${usersfile} - > ${workdir}/master.passwd
    doas tee ${etc}/master.passwd < ${workdir}/master.passwd > /dev/null
    doas pwd_mkdb -d ${etc} -p ${etc}/master.passwd

    lines "${group_members}" | while read -r group members; do
	doas pw -R ${rootdir} groupmod ${group} -m ${members}
    done

    # Hash in the image, so its login.conf picks the format.
    lines "${passwords}" | while read -r user ref; do
	doas chroot ${rootdir} pw usermod ${user} -h 0 \
	    < ${passworddir}/${user}
    done
}

# Check the finished tree the way the host will use it, so a bad image
# fails here rather than at boot.
verify_image() {
    local f group gid line user members cmd shown ref hash

    mount_dev

    for f in $(lines "${required_files}"); do
	[ -e ${rootdir}${f} ] || fail "${f} is missing"
    done
    doas pkg --rootdir ${rootdir} check -q -s -a ||
	fail "installed files do not match package checksums"

    verify_tree dist dist/dist.mtree
    verify_tree ${secretdir} secrets/secrets.mtree

    # pw reads the databases login(1) uses, so these check them too.
    lines "${groups}" | while read -r group gid; do
	[ "$(in_image pw groupshow ${group} | cut -d: -f3)" = "${gid}" ] ||
	    fail "group ${group} does not have gid ${gid}"
    done
    # A user in ${passwords} has a hash where its config has *.
    while read -r line; do
	user=${line%%:*}
	shown=$(in_image pw usershow ${user})
	if [ -e ${passworddir}/${user} ]; then
	    shown=$(echo "${shown}" | cut -d: -f1,3-)
	    line=$(echo "${line}" | cut -d: -f1,3-)
	fi
	[ "${shown}" = "${line}" ] ||
	    fail "user ${user} does not match its config"
    done < ${usersfile}

    # pw gives each hash its own random salt. Hash each password again
    # with the salt from its hash in the image; it must give that hash.
    # Only SHA-512 crypt, FreeBSD's default, is understood.
    lines "${passwords}" | while read -r user ref; do
	hash=$(in_image pw usershow ${user} | cut -d: -f2)
	case ${hash} in
	\$6\$*) ;;
	*) fail "${user} password is not a SHA-512 crypt hash" ;;
	esac
	[ "$(openssl passwd -6 -salt $(echo "${hash}" | cut -d'$' -f3) \
	    -stdin < ${passworddir}/${user})" = "${hash}" ] ||
	    fail "${user} password does not match its hash"
    done
    lines "${group_members}" | while read -r group members; do
	for user in $(echo ${members} | tr , ' '); do
	    in_image id -Gn ${user} | tr ' ' '\n' | grep -qx ${group} ||
		fail "${user} is not in ${group}"
	done
    done

    [ "$(cat ${rootdir}/var/db/zoneinfo)" = "${timezone}" ] &&
	cmp -s ${rootdir}/etc/localtime \
	    ${rootdir}/usr/share/zoneinfo/${timezone} ||
	fail "timezone is not ${timezone}"

    lines "${config_checks}" | while read -r cmd; do
	in_image ${cmd} || fail "${cmd}"
    done

    umount_dev
}

# verify_tree <dir> <mtree>: every entry in <mtree> is in the image with
# its type, owner, and mode, and each file has the same contents as in
# <dir>.
verify_tree() {
    [ -e ${2} ] || return 0

    doas mtree -e -f ${2} -p ${rootdir} ||
	fail "${2} does not match the image"

    grep '^\./' ${2} | cut -d' ' -f1 > ${workdir}/paths
    mtree -c -k sha256 -O ${workdir}/paths -p ${1} |
	doas mtree -e -p ${rootdir} ||
	fail "files in ${1} differ from the image"
}

send_be() {
    doas zfs snapshot ${pool}/ROOT/default@ready
    doas zfs send ${pool}/ROOT/default@ready > ${outfile}
}

in_image() {
    doas chroot ${rootdir} "$@" < /dev/null
}

mount_dev() {
    doas mount -t devfs devfs ${rootdir}/dev
    devmounted=yes
}

umount_dev() {
    doas umount ${rootdir}/dev
    devmounted=""
}

# pkg keeps downloaded packages in the image's /var/cache/pkg and the
# repository catalogs in /var/db/pkg/repos. Mount the builder's cache
# over both, so they outlive the image and pkg fetches only what changed.
mount_cache() {
    doas mkdir -p ${pkg_cache}/packages ${pkg_cache}/repos \
	${rootdir}/var/cache/pkg ${rootdir}/var/db/pkg/repos
    doas mount -t nullfs ${pkg_cache}/packages ${rootdir}/var/cache/pkg
    doas mount -t nullfs ${pkg_cache}/repos ${rootdir}/var/db/pkg/repos
    cachemounted=yes
}

umount_cache() {
    doas umount ${rootdir}/var/db/pkg/repos
    doas umount ${rootdir}/var/cache/pkg
    cachemounted=""
}

# Print a config list without indentation or blank lines.
lines() {
    echo "${1}" | sed -e 's/^[[:space:]]*//' -e '/^$/d'
}

# The files, not directories, in secrets/secrets.mtree.
secret_paths() {
    [ -e secrets/secrets.mtree ] || return 0
    mtree -C -k type -f secrets/secrets.mtree |
	awk '$2 == "type=file" { print $1 }'
}

fail() {
    echo "verify: $*" >&2
    exit 1
}

cleanup() {
    [ -n "${devmounted}" ] && doas umount ${rootdir}/dev || true
    if [ -n "${cachemounted}" ]; then
	doas umount ${rootdir}/var/db/pkg/repos || true
	doas umount ${rootdir}/var/cache/pkg || true
    fi
    doas zpool destroy ${pool} 2>/dev/null || true
    [ -n "${mounted}" ] && doas umount ${workdir} || true
    # If an unmount failed, the image and the pkg cache may still be
    # mounted under ${workdir}. Stay on its own filesystem, so this wipes
    # the secrets in the tmpfs but never the builder's cache.
    [ -n "${workdir}" ] && doas rm -rf -x ${workdir} || true
}

main
