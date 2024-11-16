subinclude("//build/defs:repos")

fetch_jj_cmd(
    name = "fetch",
    repo = "freebsd-src",
    url = "https://github.com/freebsd/freebsd-src.git"
)

def freebsd_release(name:str, version:str):
    clean_version = version.replace("/", "-")
    jj_repo(name = f"repo--{clean_version}", repo = "freebsd-src", version = version)

    genrule(
        name = name,
        timeout = 60 * 60 * 4, # 4 hours max
        srcs = {
            "FREEBSD_SRC": f":repo--{clean_version}",
            "BUILD_SH": "scripts/build.sh"
        },
        cmd = [
            "mkdir _build",
            "env -i PATH=${PATH} BUILDDIR=${TMP_DIR}/_build sh ${SRCS_BUILD_SH} ${SRCS_FREEBSD_SRC} > _build/build.log 2> _build/error.log",
            f"mkdir {name}",
            f"echo {clean_version} > {name}/VERSION",
            f"mv _build/rel/*.txz _build/*.log _build/pkgbase {name}",
        ],
        outs = [name]
    )

freebsd_release(name = "rel--15.0-stabweek-2024-10", version = "525a177c")
freebsd_release(name = "rel--14.2-BETA3", version = "bcd5f957")
