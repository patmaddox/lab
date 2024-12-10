subinclude("//build/defs:repos")

def buildworld(name:str, repo:str, srcs={}):
    srcs = {
        "CCACHECONF": "src.conf",
        "SRCCONF": "ccache.conf"
    } | srcs

    genrule(
        name = f"{name}--world",
        cmd = [
            f"env -i CCACHE_CONFIGPATH=$(realpath ${SRCS_CCACHECONF}) make -s -C ${SRCS_FREEBSD} -DNO_ROOT -DWITH_REPRODUCIBLE_BUILD -j $(sysctl -n hw.ncpu) SRCCONF=$(realpath ${SRCS_SRCCONF}) buildworld >{name}/buildworld.log 2>{name}/buildworld.error.log"
        ],
        env = {
            "SRCS_FREEBSD": repo,
        },
        srcs = srcs,
        outs = [f"{name}/buildworld.log", f"{name}/buildworld.error.log"]
    )

def buildkernel(name:str, repo: str, kernconf="GENERIC", srcs={}):
    srcs = {
        "CCACHECONF": "src.conf",
        "SRCCONF": "ccache.conf"
    } | srcs

    name = f"{name}--kernel"
    if kernconf != "GENERIC":
        name = f"{name}.{kernconf}"

    genrule(
        name = name,
        cmd = [
            f"env -i CCACHE_CONFIGPATH=$(realpath ${SRCS_CCACHECONF}) make -s -C ${SRCS_FREEBSD} -DNO_ROOT -DWITH_REPRODUCIBLE_BUILD -j $(sysctl -n hw.ncpu) SRCCONF=$(realpath ${SRCS_SRCCONF}) KERNCONF={kernconf} buildkernel >{name}/buildkernel.{kernconf}.log 2>{name}/buildkernel.{kernconf}.error.log"
        ],
        env = {
            "SRCS_FREEBSD": repo,
        },
        srcs = srcs,
        outs = [f"{name}/buildkernel.{kernconf}.log", f"{name}/buildkernel.{kernconf}.error.log"]
    )

def kernel_txz(name:str, repo:str, kernconf="GENERIC", srcs={}):
    srcs = {
        "CCACHECONF": "src.conf",
        "SRCCONF": "ccache.conf"
    } | srcs

    basename = f"{name}--kernel"
    kernext = "txz"
    if kernconf != "GENERIC":
        basename = f"{basename}.{kernconf}"
        kernext = f"{kernconf}.{kernext}"

    name = f"{basename}.txz"

    genrule(
        name = name,
        deps = [f":{basename}"],
        cmd = [
            f"env -i CCACHE_CONFIGPATH=$(realpath ${SRCS_CCACHECONF}) make -s -C ${SRCS_FREEBSD}/release -DNO_ROOT -DWITH_REPRODUCIBLE_BUILD -j $(sysctl -n hw.ncpu) SRCCONF=$(realpath ${SRCS_SRCCONF}) KERNCONF={kernconf} kernel.txz >{basename}/kernel.{kernext}.log 2>{basename}/kernel.{kernext}.error.log",
            f"cp $(make -C ${SRCS_FREEBSD}/release -V .OBJDIR)/kernel.txz ${OUTS_TXZ}"
        ],
        env = {
            "SRCS_FREEBSD": repo,
        },
        outs = {
            "TXZ": [f"{basename}.txz"],
            "LOGS": [f"{basename}/kernel.{kernext}.log", f"{basename}/kernel.{kernext}.error.log"]
        },
        srcs = srcs
    )

def base_txz(name:str, repo:str, srcs={}):
    srcs = {
        "CCACHECONF": "src.conf",
        "SRCCONF": "ccache.conf"
    } | srcs

    buildworld(name = "dev", repo = dev_repo, srcs)

    basename = name
    name = f"{basename}--base.txz"

    genrule(
        name = name,
        deps = [f":{basename}--world"],
        cmd = [
            f"env -i CCACHE_CONFIGPATH=$(realpath ${SRCS_CCACHECONF}) make -s -C ${SRCS_FREEBSD}/release -DNO_ROOT -DWITH_REPRODUCIBLE_BUILD -j $(sysctl -n hw.ncpu) SRCCONF=$(realpath ${SRCS_SRCCONF}) base.txz >{basename}/base.txz.log 2>{basename}/base.txz.error.log",
            f"cp $(make -C ${SRCS_FREEBSD}/release -V .OBJDIR)/base.txz ${OUTS_TXZ}"
        ],
        env = {
            "SRCS_FREEBSD": repo,
        },
        outs = {
            "TXZ": [name],
            "LOGS": [f"{basename}/base.txz.log", f"{basename}/base.txz.error.log"]
        },
        srcs = srcs
    )

dev_repo = "/home/patmaddox/lab.jj/repos/freebsd-src.jj"
base_txz(name = "dev", repo = dev_repo)
buildkernel(name = "dev", repo = dev_repo, kernconf="GENERIC-NODEBUG")
kernel_txz(name = "dev", repo = dev_repo, kernconf="GENERIC-NODEBUG")

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
        },
        visibility = ["//infra/images/..."]
    )

# build the local tree in repos/freebsd-src.jj
release(
    name = "dev",
    env = {"SRCS_FREEBSD": "/home/patmaddox/lab.jj/repos/freebsd-src.jj"}
)

release(
    name = "14.2-RELEASE",
    srcs = {"FREEBSD": ":repo--releng-142--c8918d6c"},
)
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
