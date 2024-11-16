genrule(
    name = "poudriere-builder",
    srcs = {
        "FREEBSD_TXZ": "//src/freebsd-src:rel--14.2-BETA3",
        "BUILD_SH": "scripts/build.sh",
        "DIST_FILES": glob(["dist/**/*"], exclude=["#*", "*~"])
    },
    cmd = [
        "mkdir _build",
        "doas env -i PATH=${PATH} BUILDDIR=$(realpath _build) sh ${SRCS_BUILD_SH} ${SRCS_FREEBSD_TXZ} $(dir :poudriere-builder)/dist poudriere-builder.zfs",
        "cp _build/poudriere-builder.zfs poudriere-builder.zfs",
        "doas chflags -R noschg _build",
        "doas rm -rf _build"
    ],
    outs = ["poudriere-builder.zfs"]
)
