subinclude("//build_defs:repos")

def freebsd_build(name:str, version:str):
    jj_repo(name = "freebsd-src", version = version)
    
    genrule(
        name = name,
        timeout = 60 * 60 * 4, # 4 hours max
        srcs = {
            "FREEBSD_SRC": f":freebsd-src-{version}",
            "BUILD_SH": "scripts/build.sh"
        },
        cmd = [
            "mkdir _build",
            f"echo {version} > _build/VERSION",
            "env -i PATH=${PATH} BUILDDIR=${TMP_DIR}/_build sh ${SRCS_BUILD_SH} ${SRCS_FREEBSD_SRC} > _build/stabweek.log 2> _build/stabweek.error.log",
            f"mv _build {name}"
        ],
        outs = [name]
    )

freebsd_build(name = "stabweek-2024-10", version = "525a177c1657")
