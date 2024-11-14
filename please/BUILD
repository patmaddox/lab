sh_cmd(
    name = "fetch",
    visibility = ["PUBLIC"],
    deps = [":fetch-please"],
    cmd = [
        "sh $(out_location :fetch-please)"
    ]
)

sh_cmd(
    name = "fetch-please",
    cmd = [
        "cd ./$(dirname $(location :fetch-please))",
        "if [ ! -d please.jj ]; then jj git clone https://github.com/thought-machine/please.git please.jj; fi"
    ]
)
