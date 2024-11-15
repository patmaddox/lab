## fetch everything
fetch_deps = [
    "//repos:fetch",
]

fetch_cmds = map(
    lambda d: f"sh $(out_location {d})",
    fetch_deps,
)

sh_cmd(
    name = "fetch",
    cmd = fetch_cmds,
    deps = fetch_deps,
)
