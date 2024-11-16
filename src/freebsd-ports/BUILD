subinclude("//build/defs:repos")

fetch_jj_cmd(
    name = "fetch",
    repo = "freebsd-ports",
    url = "git@github.com:patmaddox/freebsd-ports.git",
    remotes = [{
        "name": "upstream",
        "url": "https://github.com/freebsd/freebsd-ports.git",
    }]
)

sh_cmd(
    name = "list-ports",
    cmd = [
        "cd $(dir :list-ports)",
        "sh scripts/list-ports.sh > $(hostname -s).ports",
    ],
)

jj_repo(
    name = "repo--main",
    repo = "freebsd-ports",
    version = "main"
)

genrule(
    name = "poudriere-ports--main",
    deps = [":repo--main"],
    cmd = [
        "doas poudriere ports -c -p main -m null -M $(plz query reporoot)/$(out_location :repo--main)",
        "poudriere ports -l -q | grep '^main[[:space:]]' > main.txt"
    ],
    outs = ["main.txt"]
)

filegroup(
    name = "ports-files",
    srcs = glob(["*.ports"])
)

sh_cmd(
    name = "bulk",
    deps = [":poudriere-ports--main"],
    cmd = [
        "doas poudriere bulk -b latest -j 14-stable -p main \\\${@}",
    ],
)

genrule(
    name = "packages--14-stable-main",
    srcs = {
        "BULK_SH": ":bulk",
        "PORTS_FILES": ":ports-files"
    },
    cmd = [
        "echo ${SRCS_PORTS_FILES} | sed -e 's/[[:space:]]/ -f /g' -e 's/^/-f /' | xargs ./${SRCS_BULK_SH} -N",
        "pkg repo -o packages/14-stable-main /usr/local/poudriere/data/packages/14-stable-main/.latest/All"
    ],
    outs = ["packages/14-stable-main"]
)
