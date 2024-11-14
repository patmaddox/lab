sh_cmd(
    name = "fetch",
    deps = [
        "//freebsd-ports:fetch",
        "//jj:fetch",
        "//please:fetch",
    ],
    cmd = [
        "sh $(out_location //freebsd-ports:fetch)",
        "sh $(out_location //jj:fetch)",
        "sh $(out_location //please:fetch)"
    ]
)
