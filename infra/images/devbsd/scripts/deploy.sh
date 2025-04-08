#!/bin/sh
set -eu
set -o pipefail

image_name=${1}; shift
src_image_file=${1}; shift
dst_image_file=/vm/${image_name}/${image_name}.zfs

zroot=""
timestamp=$(TZ=UTC date "+%s")
before_snapshot=before-deploy-${timestamp}
after_snapshot=after-deploy-${timestamp}

main() {
    snapshot-existing-image
    cp-image-file
    cp-ssh-host-keys
    update-image
}

snapshot-existing-image() {
    zroot=$(zfs list -H ${dst_image_file} | awk '{print $1}')
    zfs snapshot ${zroot}@${before_snapshot}
}

cp-image-file() {
    cp ${src_image_file} ${dst_image_file}.next
}

cp-ssh-host-keys() {
    local orig_image orig_md next_md
    orig_image=/vm/${image_name}/.zfs/snapshot/${before_snapshot}/${image_name}.zfs

    orig_md=$(mdconfig -a -f ${orig_image} -o readonly | sed -e 's/^md//')
    zpool import -d /dev/md${orig_md} -f -o readonly=on -R /tmp/${image_name}-orig -t zroot ${image_name}-orig

    next_md=$(mdconfig -a -f ${dst_image_file}.next | sed -e 's/^md//')
    zpool import -d /dev/md${next_md} -R /tmp/${image_name}-next -t zroot ${image_name}-next

    cp /tmp/${image_name}-orig/etc/ssh/ssh_host_*_key* /tmp/${image_name}-next/etc/ssh/

    zpool export ${image_name}-next
    mdconfig -d -u ${next_md}

    zpool export ${image_name}-orig
    mdconfig -d -u ${orig_md}
}

update-image() {
    local is_running

    set +o pipefail
    if vm list -r | grep -q "^${image_name}[[:space:]]"; then
	is_running="yes"
	vm stop ${image_name}
	while vm list -r | grep -q "^${image_name}[[:space:]]"; do
	    sleep 3
	done
	set -o pipefail
    fi

    cp ${dst_image_file}.next ${dst_image_file}
    zfs snapshot ${zroot}@${after_snapshot}

    if [ -n "${is_running}" ]; then
	vm start ${image_name}
    fi
}

main "#{@}"
