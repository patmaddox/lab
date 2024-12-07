#!/bin/sh
set -eu

repo="https://github.com/thought-machine/please.git"
tag="v17.12.5"
trunk="master"
trunkdir="${trunk}.jj"

main() {
    local curdir cmd repodir destdir
    curdir=$(pwd)
    repodir=${1:?missing repodir arg}; shift
    destdir=${1:?missing destdir arg}; shift

    clone

    if [ ! -f ${destdir}/plz ]; then
	bootstrap
	install
    fi
}

clone() {
    if [ ! -d ${repodir} ]; then
	jj git clone ${repo} ${repodir}
    fi
    repodir=$(realpath ${repodir})
}

bootstrap() {
    cd ${repodir}
    jj new ${tag}
    ./bootstrap.sh --skip_tests
    cd ${curdir}
}

install() {
    cp ${repodir}/plz-out/bin/src/please ${destdir}/plz
}

main "${@}"
