subinclude("//build/defs:repos")

jj_repo(
    name = "repo--main",
    repo = "freebsd-ports",
    version = "7fd38b1a",
    visibility = ["//infra/images/..."]
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

def built_packages(name:str):
    genrule(
        name = f"packages--{name}",
        srcs = {
            "REPOS_DIR": "repos"
        },
        cmd = [
            f"mkdir -p pkgroot packages/{name}",
            f"env REPOS_DIR=$(realpath ${SRCS_REPOS_DIR}) INSTALL_AS_USER=yes pkg -r pkgroot fetch -a -y -r {name} -o $(realpath packages/{name}) > packages/{name}/build.log 2>packages/{name}/error.log",
            f"pkg repo -o $(realpath packages/{name}) packages/{name}"
        ],
        outs = [f"packages/{name}"],
        visibility = ["//infra/..."]
    )

built_packages("141-default")
built_packages("142-default")
