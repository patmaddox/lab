#!/bin/sh
set -eu

main() {
    local zpoolfile zfsroot
    zpool=plz-beastie
    zpoolfile=${BUILDDIR}/${zpool}-tmp.zfs
    zfsroot=/tmp/${zpool}
    outfile=${BUILDDIR}/beastie.zfs

    create-zpool
    extract-base
    copy-config
    copy-datafiles
    install-packages
    copy-usergroup
    finalize
}

create-zpool() {
    truncate -s 30g ${zpoolfile}
    zpool create -m / -R ${zfsroot} ${zpool} ${zpoolfile}
}

extract-base() {
    local t
    for t in base kernel; do
	tar -C ${zfsroot} -xf ${FREEBSD_REL}/${t}.txz
    done
}

copy-config() {
    tar -c -C ${DISTDIR} . | tar -x -C ${zfsroot} --gid 0 --uid 0
}

copy-usergroup() {
    sh ${SYNC_PW_SH} /etc ${zfsroot}/etc u root patmaddox
    sh ${SYNC_PW_SH} /etc ${zfsroot}/etc g wheel patmaddox video webcamd
}

copy-datafiles() {
    tzsetup -C ${zfsroot} America/Los_Angeles
    cp /etc/ssh/ssh_host_*_key* ${zfsroot}/etc/ssh
}

install-packages() {
    mkdir ${zfsroot}/packages
    mount_nullfs ${PACKAGES} ${zfsroot}/packages

    pkgrepos=${zfsroot}/usr/local/etc/pkg/repos
    mkdir -p ${pkgrepos}
    cat <<EOF > ${pkgrepos}/plz.conf
    plz {
      url: "file:///packages",
      enabled: yes
    }
EOF

    pkg -c ${zfsroot} install -y -r plz $(cat ${PORTSFILE} | xargs)
    rm ${pkgrepos}/plz.conf
    umount ${zfsroot}/packages
    rmdir ${zfsroot}/packages
}

finalize() {
    zfs set mountpoint=none ${zpool}
    zfs snapshot ${zpool}@init
    zfs send ${zpool}@init > ${outfile}
    zpool export ${zpool}
}

main
