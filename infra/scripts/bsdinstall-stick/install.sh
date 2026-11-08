#!/bin/sh
#
# install.sh <disk>
#
# Install a host onto <disk> from an installer stick built by
# bsdinstall-stick.sh. bsdinstall lays out the disk and installs the
# stock system, as a boot environment named default. Then the host's
# boot environment goes in beside it, is activated, and default is
# destroyed.
#
# install.conf, beside this script, sets:
#
#   be         the name to import the boot environment as
#   stream     the file holding its ZFS send stream
#   swap_size  the swap partition's size, or 0 for none
set -eu

here=$(dirname $(realpath ${0}))
pool=zroot

. ${here}/install.conf

: ${be:?} ${stream:?} ${swap_size:?}

if [ ${#} -ne 1 ]; then
    geom disk list | grep -E '^Geom name:|Mediasize:|descr:'
    echo "Usage: sh ${0} <disk>"
    exit 1
fi
disk=${1}

[ -c /dev/${disk} ] || { echo "No such disk: ${disk}"; exit 1; }

echo "Installing ${be}. Everything on ${disk} will be destroyed:"
geom disk list ${disk} | grep -E 'Mediasize:|descr:'
printf "Type %s again to continue: " ${disk}
read answer
[ "${answer}" = "${disk}" ] || { echo "Stopped."; exit 1; }

export ZFSBOOT_DISKS=${disk}
export ZFSBOOT_SWAP_SIZE=${swap_size}
bsdinstall script ${here}/installerconfig

# bsdinstall's post-install section cannot do this. It runs chrooted in
# the default boot environment, so it can neither see the stick nor
# destroy default. bsdinstall exports the pool when it is done.
zpool import -N -R /mnt ${pool}
bectl -r ${pool}/ROOT import ${be} < ${here}/${stream}
bectl -r ${pool}/ROOT activate ${be}
bectl -r ${pool}/ROOT destroy default
bectl -r ${pool}/ROOT list
zpool export ${pool}

echo "${be} is installed on ${disk}. Remove the stick and reboot."
