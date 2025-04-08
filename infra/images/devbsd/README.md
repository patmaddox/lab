# devbsd

A VM image for FreeBSD CURRENT, intended to be used for development.

1. Build the image
2. Deploy it with bhyve
3. Edit code locally, build on devbsd

It is configured to NFS mount the main source code to `/usr/src`.

Tip: `cd /usr/src && DESTDIR=/tmp/newworld make builddenv`

It is built as a raw ZFS image that can be directly loaded with `bhyveload(8)`.

## Example bhyve configuration

```
loader="bhyveload"
cpu=16
memory=32G
network0_type="virtio-net"
network0_switch="jails"
disk0_type="ahci-hd"
disk0_name="devbsd.zfs"
```

## SSH host keys

The first time the image boots up, it will write SSH host keys to `/etc/ssh/`.
After rebuilding the image, the host keys will be gone.
It is simple to extract the host keys from the original image and copy them to the new one:

```
mdconfig -a devbsd.zfs
zpool import -o readonly=on -R /tmp/devbsd-orig -t zroot devbsd-orig

mdconfig -a devbsd.next.zfs
zpool import -R /tmp/devbsd-next -t zroot devbsd-next

cp /tmp/devbsd-orig/etc/ssh/ssh_host_*_key* /tmp/devbsd-next/etc/ssh/

zpool export devbsd-next
zpool export devbsd-orig

# clean up the mdconfigs e.g. mdconfig -d -u 1
```

## zpool guid

`makefs` creates datasets with a fixed guid. (https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=282832)
zfs cannot import two pools with the same guid - it simply won't see the other one.
Images should be created with a unique guid, or set `zfs_reguid="yes"` in `rc.conf` as done here.
