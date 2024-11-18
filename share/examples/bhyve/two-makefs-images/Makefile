# Example demonstrating bhyve boot failure when it has two new makefs
# images attached.
#
# Usage:
# make run	-- this fails to boot
# make destroy
# make run	-- again, to make sure it isn't fixed by booting
# make destroy
# make reguid
# make run	-- this succeeds

.PHONY: run destroy clean clean-zfs reguid zfs

RELEASE=	14.2-BETA3
TAP=		tap2

run: zfs
	bhyveload -m 2G -d _build/zroot.zfs two-makefs-images
	bhyve -c 2 -m 2G -A -H -P \
		-s 0:0,hostbridge \
		-s 1:0,virtio-net,${TAP} \
		-s 2:0,ahci-hd,_build/zroot.zfs \
		-s 3:0,ahci-hd,_build/zdata.zfs \
		-s 31,lpc -l com1,stdio \
		two-makefs-images

reguid: _build/zroot.zfs _build/zdata.zfs
	mdid=$$(mdconfig -a -f _build/zroot.zfs | grep -o '[[:digit:]]*') && zpool import -t -R /tmp/my-zroot zroot tmp-myzroot && zpool reguid tmp-myzroot && zpool export tmp-myzroot && mdconfig -d -u $${mdid}
	mdid=$$(mdconfig -a -f _build/zdata.zfs | grep -o '[[:digit:]]*') && zpool import -t -R /tmp/my-zdata zdata tmp-myzdata && zpool reguid tmp-myzdata && zpool export tmp-myzdata && mdconfig -d -u $${mdid}

zfs: _build/zroot.zfs _build/zdata.zfs

destroy:
	bhyvectl --destroy --vm two-makefs-images

clean: clean-zfs
	rm -rf _build

clean-zfs:
	if [ -d _build/zroot ]; then chflags -R noschg _build/zroot; fi
	rm -rf _build/zroot _build/zdata _build/*.zfs

_build/zroot.zfs: _build/zroot/COPYRIGHT
	makefs -t zfs \
		-s 10g \
		-o poolname=zroot \
		${.TARGET} _build/zroot

_build/zroot/COPYRIGHT: _build/src.txz _build/kernel.txz
	mkdir -p _build/zroot
	tar -C _build/zroot -xf _build/src.txz
	tar -C _build/zroot -xf _build/kernel.txz
	sysrc -f _build/zroot/etc/rc.conf zfs_enable="YES"
	sysrc -f _build/zroot/etc/rc.conf zpool_reguid=zroot
	sysrc -f _build/zroot/boot/loader.conf zfs_load=YES
	touch ${.TARGET}

_build/zdata.zfs:
	mkdir -p _build/zdata/subdir
	makefs -t zfs -s 100m \
		-o poolname=zdata \
		-o rootpath=/zdata \
		${.TARGET} _build/zdata

_build/src.txz:
	mkdir -p _build
	fetch -o ${.TARGET} https://download.freebsd.org/releases/amd64/${RELEASE}/base.txz

_build/kernel.txz:
	mkdir -p _build
	fetch -o ${.TARGET} https://download.freebsd.org/releases/amd64/${RELEASE}/kernel.txz
