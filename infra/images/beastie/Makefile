BENAME=		beastie-14.2-RELEASE-2025-01-02
BE=		zroot/ROOT/${BENAME}
BEROOT=		/tmp/be_mount-${BENAME}
OPTROOT=	${BEROOT}/opt

DOWNLOAD_ROOT=	https://download.freebsd.org/releases/amd64/14.2-RELEASE

USERS=		root patmaddox
GROUPS=		wheel patmaddox video webcamd
SYNC_PW!=	realpath ${.CURDIR}/../../../src/sync-pw/sync-pw

DOAS=		/usr/local/bin/doas
TZ=		America/Los_Angeles

.PHONY: all ${BE} freebsd config packages packages_config data mount umount

all: data

freebsd: ${OPTROOT}/log/1_install_freebsd.log
config: ${OPTROOT}/log/2_freebsd_config.log
packages: ${OPTROOT}/log/3_packages.log
packages_config: ${OPTROOT}/log/4_packages_config.log
data: ${OPTROOT}/log/5_data.log

mount:
	${DOAS} bectl mount ${BE} ${BEROOT}

umount:
	${DOAS} bectl umount ${BE}

# do not create the 0_start.log as part of this step, but rather it
# may be brought in via a mount
${OPTROOT}/log/0_start.log:
	zfs list ${BE} >/dev/null 2>&1 || ${DOAS} zfs create -o mountpoint=none ${BE}
	bectl list | awk 'BEGIN { status = 1 }; $$1 == "${BENAME}" && $$3 == "${BEROOT}" { status = 0 }; END { exit status }' || ${DOAS} bectl mount ${BE} ${BEROOT}
	zfs list ${BE}@empty >/dev/null 2>&1 || ${DOAS} zfs snapshot ${BE}@empty

${OPTROOT}/log/1_install_freebsd.log: ${OPTROOT}/log/0_start.log
	${DOAS} mkdir -p ${.TARGET:H}
	: | ${DOAS} tee ${.ALLSRC}
	${DOAS} chmod 444 ${.ALLSRC}

	fetch -o - ${DOWNLOAD_ROOT}/base.txz | ${DOAS} tar -C ${BEROOT} -x
	fetch -o - ${DOWNLOAD_ROOT}/kernel.txz | ${DOAS} tar -C ${BEROOT} -x
	: | ${DOAS} tee ${.TARGET}
	${DOAS} chmod 444 ${.TARGET}
	${DOAS} zfs snapshot ${BE}@freebsd

${OPTROOT}/log/2_freebsd_config.log: ${OPTROOT}/log/1_install_freebsd.log
	tar -C dist -c @base.mtree | ${DOAS} tar -C ${BEROOT} -x
	${DOAS} cp ${BEROOT}/usr/share/zoneinfo/${TZ} ${BEROOT}/etc/localtime
	: | ${DOAS} tee ${.TARGET}
	${DOAS} chmod 444 ${.TARGET}
	${DOAS} zfs snapshot ${BE}@freebsd_config

${OPTROOT}/log/3_packages.log: ${OPTROOT}/log/2_freebsd_config.log
	${DOAS} env PKG_CACHEDIR=/var/cache/pkg pkg -r ${BEROOT} install -r FreeBSD -y $$(cat beastie.ports) | ${DOAS} tee ${.TARGET}.tmp
	${DOAS} mv ${.TARGET}.tmp ${.TARGET}
	${DOAS} chmod 444 ${.TARGET}
	${DOAS} zfs snapshot ${BE}@packages

${OPTROOT}/log/4_packages_config.log: ${OPTROOT}/log/3_packages.log
	tar -C dist -c @packages.mtree | ${DOAS} tar -C ${BEROOT} -x
	: | ${DOAS} tee ${.TARGET}
	${DOAS} chmod 444 ${.TARGET}
	${DOAS} zfs snapshot ${BE}@packages_config

${OPTROOT}/log/5_data.log: ${OPTROOT}/log/4_packages_config.log
	${DOAS} tar -C / -c @${.CURDIR}/dist/data.mtree | ${DOAS} tar -C ${BEROOT} -x
	${DOAS} ${SYNC_PW} /etc ${BEROOT}/etc u ${USERS}
	${DOAS} ${SYNC_PW} /etc ${BEROOT}/etc g ${GROUPS}
	: | ${DOAS} tee ${.TARGET}
	${DOAS} chmod 444 ${.TARGET}
	${DOAS} zfs snapshot ${BE}@data
