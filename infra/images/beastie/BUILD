export_file(
    name = "portsfile",
    src = "beastie.ports",
    visibility = ["//infra/images/poudriere-builder:portsfiles"]
)

genrule(
    name = "beastie",
    outs = ["beastie.zfs", "build.log", "error.log"],
    srcs = {
        "FREEBSD_REL": "//src/freebsd-src:rel--14.2-RELEASE",
        "PACKAGES": "//src/freebsd-ports:packages--142-default",
        "PORTSFILE": ":portsfile",
        "DISTDIR": "dist",
        "BUILD_SH": "scripts/build.sh",
        "SYNC_PW_SH": "//src/sync-pw"
    },
    cmd = [
        "mkdir _build",
        f"doas env -i PATH=${PATH} BUILDDIR=$(realpath _build) FREEBSD_REL=$(realpath ${SRCS_FREEBSD_REL}) PACKAGES=$(realpath ${SRCS_PACKAGES}) DISTDIR=$(realpath ${SRCS_DISTDIR}) PORTSFILE=$(realpath ${SRCS_PORTSFILE}) SYNC_PW_SH=${SRCS_SYNC_PW_SH} sh ${SRCS_BUILD_SH} > _build/build.log 2> _build/error.log",
        f"cp _build/beastie.zfs _build/*.log ./",
        "doas rm -rf _build"
    ],
)
