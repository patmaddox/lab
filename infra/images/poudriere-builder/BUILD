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
            "DIST_FILES": glob(["dist/**/*"], exclude=["#*", "*~"]),
            "FREEBSD_REL": ":freebsd-rel",
            "FREEBSD_TXZ": f"//src/freebsd-src:rel--{version}",
            "PORTS": "//src/freebsd-ports:repo--main",
        },
        cmd = [
            "mkdir _build",
            f"doas env -i PATH=${PATH} BUILDDIR=$(realpath _build) PORTSDIR=${SRCS_PORTS} FREEBSD_REL=\"${SRCS_FREEBSD_REL}\" sh ${SRCS_BUILD_SH} ${SRCS_FREEBSD_TXZ} $(dir :{name})/dist {name}.zfs > _build/build.log 2> _build/error.log",
            f"cp _build/{name}.zfs .",
            "doas chflags -R noschg _build",
            "doas rm -rf _build"
        ],
        outs = [f"{name}.zfs"]
    )

poudriere_builder(version = "14.2-BETA3")
poudriere_builder(version = "15.0-stabweek-2024-10")
