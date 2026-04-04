#!/bin/sh
set -eu

# Example demonstrating how please will refuse to include a src dir if
# it has a BUILD file in it
#
# https://github.com/thought-machine/please/issues/3296

root=$(mktemp -d -t plz-subdir)

main() {
    init-repo
    init-subrepo
    plz-build
}

init-repo() {
    cd ${root}
    plz init

    cat <<EOF >> .plzconfig

[parse]
blacklistdirs = subrepo
EOF

    cat <<EOF > BUILD
filegroup(
    name = "subrepo",
    srcs = ["subrepo"],
)
EOF
}

init-subrepo() {
    cd ${root}
    mkdir subrepo
    cd subrepo
    yes | plz init
    touch BUILD
}

plz-build() {
    cd ${root}
    plz build :subrepo
}

main
