subinclude("//build/defs:repos")

def release(name:str, kernconf:str="GENERIC", env:dict={}, srcs:dict={}):
    srcs = {
        "BUILD": "scripts/build.sh",
        "CCACHE_CONF": "ccache.conf",
        "SRCCONF": "src.conf"
    } | srcs

    env = {
        "KERNCONF": kernconf,
    } | env

    genrule(
        name = f"rel--{name}",
        timeout = 60 * 60 * 4, # 4 hours max
        env = env,
        srcs = srcs,
        tools = {
            "DOAS": "doas"
        },
        cmd = [
            "sh ${SRCS_BUILD} all"
        ],
        outs = {
            "PKGBASE_DIR": [f"pkgbase/{name}"],
            "REL_DIR": [f"rel/{name}"],
        }
    )

# build the local tree in repos/freebsd-src.jj
release(
    name = "dev",
    srcs = {"DEV_HEAD": "dev-head"},
    env = {"SRCS_FREEBSD": "/home/patmaddox/lab.jj/repos/freebsd-src.jj"}
)

release(name = "14.2-RELEASE", srcs = {"FREEBSD": ":repo--releng-142--c8918d6c"})
jj_repo(
    name = f"repo--releng-142--c8918d6c",
    repo = "freebsd-src",
    version = "c8918d6c",
)

release(name = "15.0-stabweek-2024-10", srcs = {"FREEBSD": ":repo--main-150-stabweek-2024-10--525a177c"}, kernconf ="GENERIC-NODEBUG")
jj_repo(
    name = f"repo--main-150-stabweek-2024-10--525a177c",
    repo = "freebsd-src",
    version = "525a177c",
)

release(name = "14.1-RELEASE-p6", srcs = {"FREEBSD": ":repo--releng-141-p6--74b6c983"})
jj_repo(
    name = f"repo--releng-141-p6--74b6c983",
    repo = "freebsd-src",
    version = "74b6c983",
)
