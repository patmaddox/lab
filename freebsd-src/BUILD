subinclude("//build_defs:fetch_repos")

fetch_repos([{
    "name": "freebsd-src",
    "url": "https://github.com/freebsd/freebsd-src.git",
}])

# stabweek-2024-10: 525a177c1657

filegroup(
    name = "freebsd-src.jj",
    srcs = ["freebsd-src.jj"]
)

genrule(
    name = "stabweek-2024-10",
    timeout = 60 * 60 * 4, # 4 hours max
    srcs = {
        "FREEBSD_SRC": ":freebsd-src.jj",
        "BUILD_SH": "scripts/build.sh"
    },
    cmd = [
        "sh ${SRCS_BUILD_SH} ${SRCS_FREEBSD_SRC} 525a177c1657 > stabweek.log 2> stabweek.error.log",
    ],
    outs = ["stabweek.log", "stabweek.error.log", "rel-525a177c1657/base.txz", "rel-525a177c1657/kernel.txz", "rel-525a177c1657/tests.txz"]
)
