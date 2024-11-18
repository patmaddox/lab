filegroup(
    name = "freebsd-rel",
    srcs = {
        "FREEBSD_15_STABWEEK_2024_10": "//src/freebsd-src:rel--15.0-stabweek-2024-10",
        "FREEBSD_142_BETA3": "//src/freebsd-src:rel--14.2-BETA3",
        "FREEBSD_141_RELEASE_P6": "//src/freebsd-src:rel--14.1-RELEASE-p6"        
    }
)

def poudriere_builder(version:str):
    name = f"poudriere-builder-{version}"
    
    genrule(
        name = name,
        srcs = {
            "BUILD_SH": "scripts/build.sh",
            "DISTFILES": glob(["dist/zroot/*"], exclude=["#*", "*~"]),
            "FREEBSD_REL": ":freebsd-rel",
            "FREEBSD_TXZ": f"//src/freebsd-src:rel--{version}",
            "PORTS": "//src/freebsd-ports:repo--main",
        },
        cmd = [
            "mkdir _build",
            f"doas env -i PATH=${PATH} BUILDDIR=$(realpath _build) PORTSDIR=${SRCS_PORTS} FREEBSD_REL=\"${SRCS_FREEBSD_REL}\" DISTDIR=$(realpath $(dir :{name})/dist/zroot) sh ${SRCS_BUILD_SH} ${SRCS_FREEBSD_TXZ} {name} > _build/build.log 2> _build/error.log",
            f"cp _build/{name}.img _build/{name}.zfs .",
            "doas chflags -R noschg _build",
            "doas rm -rf _build"
        ],
        outs = [f"{name}.img", f"{name}.zfs"]
    )

poudriere_builder(version = "15.0-stabweek-2024-10")

genrule(
    name = "zdata",
    srcs = {
        "BUILD_ZDATA_SH": "scripts/build_zdata.sh",
        "DISTFILES": glob(["dist/zdata/*"], exclude=["#*", "*~"]),
    },
    cmd = [
        "mkdir _build",
        "doas env -i PATH=${PATH} BUILDDIR=_build DISTDIR=$(realpath $(dir :zdata)/dist/zdata) sh ${SRCS_BUILD_ZDATA_SH} > build.log 2> error.log",
        "cp _build/zdata.zfs _build/zdata.img .",
        "cp build.log zdata.log",
        "cp error.log zdata_error.log",
        "doas rm -rf _build"
    ],
    outs = ["zdata.img", "zdata.zfs", "zdata.log", "zdata_error.log"]
)
