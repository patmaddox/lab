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
