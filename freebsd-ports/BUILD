subinclude("//build_defs:fetch_repos")

fetch_repos([{
    "name": "freebsd-ports",
    "url": "git@github.com:patmaddox/freebsd-ports.git",
    "remotes": [{
        "name": "upstream",
        "url": "https://github.com/freebsd/freebsd-ports.git",
    }],
}])

sh_cmd(
    name = "list-ports",
    cmd = [
        "cd $(dir :list-ports)",
        "sh scripts/list-ports.sh > $(hostname -s).ports",
    ],
)
