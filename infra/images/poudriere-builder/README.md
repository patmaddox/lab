# freebsd-builder

Build one of the builder images and copy the outfile somewhere:

```sh
plz build //infra/images/poudriere-builder:poudriere-builder-15.0-stabweek-2024-10
mkdir /tmp/bhyve-pb
cp plz-out/gen/infra/images/poudriere-builder/poudriere-builder-15.0-stabweek-2024-10.* /tmp/bhyve-pb
```

Run it with bhyve. Resize it first so it has room to build ports.

```sh
truncate -s 120G /tmp/bhyve-pb/poudriere-builder-15.0-stabweek-2024-10.img

bhyve -c 16 -m 32G -A -H -P \
  -s 0:0,hostbridge \
  -s 1:0,virtio-net,tap1 \
  -s 2:0,ahci-hd,/tmp/bhyve-pb/poudriere-builder-15.0-stabweek-2024-10.img \
  -s 31,lpc -l com1,stdio \
  -l bootrom,/usr/local/share/uefi-firmware/BHYVE_UEFI.fd \
  pb
```

## Bootstrap script

The image includes a bootstrap script at `/opt/bin/bootstrap.sh`.
It expands the zpool to use the entire drive, and bootstraps
poudriere.

```sh
sh /opt/bin/bootstrap.sh
```

## Create jails and ports - then build

The image includes release `.txz` files in `/opt/distfiles/freebsd-rel`.
Use these to create a jail.
It has the ports tree at `/usr/ports`.

```sh
poudriere jail -c -j 141 -K GENERIC -m url=file:///opt/distfiles/freebsd-rel/14.1-RELEASE-p6 -v 14.1-RELEASE-p6
poudriere ports -c -m null -M /usr/ports
mkdir /usr/local/poudriere/data/distfiles
poudriere bulk -j 141 ports-mgmt/poudriere-devel
```
