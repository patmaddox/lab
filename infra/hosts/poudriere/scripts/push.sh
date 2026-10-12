#!/bin/sh
set -eu
set -o pipefail

remote_host="root@andre"

vm_state=$(ssh ${remote_host} vm info poudriere | awk '$1 == "state:" {print $2}')
if [ "${vm_state}" != "stopped" ]; then
	echo "E: vm state is ${vm_state}; must be stopped" >&2
	exit 1
fi

scp poudriere.img ${remote_host}:/vm/poudriere/disk-zroot/poudriere.img.tmp
ssh ${remote_host} truncate -s +20g /vm/poudriere/disk-zroot/poudriere.img.tmp
ssh ${remote_host} mv /vm/poudriere/disk-zroot/poudriere.img.tmp /vm/poudriere/disk-zroot/poudriere.img
