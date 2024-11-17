def poudriere_builder(version:str):
    name = f"poudriere-builder-{version}"
    
    genrule(
        name = name,
        srcs = {
            "FREEBSD_TXZ": f"//src/freebsd-src:rel--{version}",
            "BUILD_SH": "scripts/build.sh",
            "DIST_FILES": glob(["dist/**/*"], exclude=["#*", "*~"])
        },
        cmd = [
            "mkdir _build",
            f"doas env -i PATH=${PATH} BUILDDIR=$(realpath _build) sh ${SRCS_BUILD_SH} ${SRCS_FREEBSD_TXZ} $(dir :{name})/dist {name}.zfs",
            f"cp _build/{name}.zfs .",
            "doas chflags -R noschg _build",
            "doas rm -rf _build"
        ],
        outs = [f"{name}.zfs"]
    )

poudriere_builder(version = "14.2-BETA3")
