# freebsd-builder

Build one of the builder images and copy the outfile somewhere:

```sh
plz build //infra/images/poudriere-builder:poudriere-builder-15.0-stabweek-2024-10
cp plz-out/gen/infra/images/poudriere-builder/poudriere-builder-15.0-stabweek-2024-10.zfs /tmp
```

Run it with bhyve. Resize it first so it has room to build ports:

```sh
truncate -s 120G /tmp/poudriere-builder-15.0-stabweek-2024-10.zfs

doas bhyveload -m 32G -d /tmp/poudriere-builder-15.0-stabweek-2024-10.zfs pb-15.0

doas bhyve -c 16 -m 32G -A -H -P \
  -s 0:0,hostbridge \
  -s 1:0,virtio-net,tap1 \
  -s 2:0,ahci-hd,/tmp/poudriere-builder-15.0-stabweek-2024-10.zfs \
  -s 31,lpc -l com1,stdio \
  pb-15.0
```

## Bootstrap script

The image includes a bootstrap script at `/opt/bin/bootstrap.sh`.
It does the following things:

Expand the zpool to use the entire drive:

```sh
zpool online -e zroot ada0
```

Bootstrap poudriere:

```sh
for p in ports-mgmt/pkg ports-mgmt/poudriere-devel; do
  cd /usr/ports/${p}
  make -D BATCH install
done
```

## Create jails

The image includes release `.txz` files in `/opt/distfiles/freebsd-rel`.
Use these to create a jail:

```sh
poudriere jail -c -j 141 -K GENERIC -m url=file:///opt/distfiles/freebsd-rel/14.1-RELEASE-p6 -v 14.1-RELEASE-p6
```
