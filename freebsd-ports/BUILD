sh_cmd(
    name = "list-ports",
    cmd = [
        "cd $(dir :list-ports)",
        "sh scripts/list-ports.sh > $(hostname -s).ports",
    ],
)

sh_cmd(
    name = "bulk",
    cmd = [
        "cd $(dir :bulk)",
        "ls *.ports | sed -e 's/^/-f /' | xargs doas poudriere bulk -b latest -j 14-stable -p main",
    ],
)
