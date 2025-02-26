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

    if [ ! -d ${repodir} ]; then
	echo "E: clone ${repodir} first" 1>&2
	exit 1
    fi

    repodir=$(realpath ${repodir})
    if [ ! -f ${destdir}/plz ]; then
	bootstrap
	install
    fi
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
