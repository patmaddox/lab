sh_cmd(
    name = "fetch",
    visibility = ["PUBLIC"],
    deps = [":fetch-jj"],
    cmd = [
        "sh $(out_location :fetch-jj)"
    ]
)

sh_cmd(
    name = "fetch-jj",
    cmd = [
        "cd ./$(dirname $(location :fetch-jj))",
        "if [ ! -d jj.jj ]; then jj git clone https://github.com/martinvonz/jj.git jj.jj; fi"
    ]
)
