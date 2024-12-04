subinclude("//build/defs:repos")

fetch_jj_cmd(
    name = "fetch",
    repo = "freebsd-src",
    url = "https://github.com/freebsd/freebsd-src.git"
)

def freebsd_release(name:str, version:str, kernconf:str="GENERIC"):
    clean_version = version.replace("/", "-")
    jj_repo(
        name = f"repo--{clean_version}",
        repo = "freebsd-src",
        version = version,
    )

    genrule(
        name = name,
        timeout = 60 * 60 * 4, # 4 hours max
        srcs = {
            "BUILD_SH": "scripts/build.sh",
            "CCACHE_CONF": "ccache.conf",
            "FREEBSD_SRC": f":repo--{clean_version}",
            "SRCCONF": "src.conf",
        },
        cmd = [
            "mkdir _build",
            f"doas env -i PATH=${PATH} BUILDDIR=$(realpath _build) SRCDIR=$(realpath ${SRCS_FREEBSD_SRC}) SRCCONF=$(realpath ${SRCS_SRCCONF}) KERNCONF={kernconf} CCACHE_CONFIGPATH=$(realpath ${SRCS_CCACHE_CONF}) sh ${SRCS_BUILD_SH} > _build/build.log 2> _build/error.log",
            f"mkdir {name}",
            f"echo {name}:{clean_version} > {name}/VERSION",
            f"cp _build/rel/*.txz _build/rel/MANIFEST _build/*.log {name}/",
            f"cp -Rp _build/pkgbase {name}/",
            "doas chflags -R noschg _build && doas rm -rf _build"
        ],
        outs = [name],
        visibility = ["//infra/images/..."]
    )

freebsd_release(name = "rel--15.0-stabweek-2024-10", version = "525a177c", kernconf ="GENERIC-NODEBUG")
freebsd_release(name = "rel--14.2-RELEASE", version = "c8918d6c")
freebsd_release(name = "rel--14.1-RELEASE-p6", version = "74b6c983")
