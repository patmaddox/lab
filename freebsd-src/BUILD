subinclude("//build_defs:repos")

def freebsd_build(name:str, version:str):
    jj_repo(name = "freebsd-src", version = version)
    version = version.replace("/", "-")
    
    genrule(
        name = name,
        timeout = 60 * 60 * 4, # 4 hours max
        srcs = {
            "FREEBSD_SRC": f":freebsd-src-{version}",
            "BUILD_SH": "scripts/build.sh"
        },
        cmd = [
            "mkdir _build",
            "env -i PATH=${PATH} BUILDDIR=${TMP_DIR}/_build sh ${SRCS_BUILD_SH} ${SRCS_FREEBSD_SRC} > _build/build.log 2> _build/error.log",
            f"mkdir {name}",
            f"echo {version} > {name}/VERSION",
            f"mv _build/rel/*.txz _build/*.log {name}",
        ],
        outs = [name]
    )

freebsd_build(name = "stabweek-2024-10", version = "525a177c1657")
