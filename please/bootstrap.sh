#!/bin/sh
set -eu

repo="https://github.com/thought-machine/please.git"
tag="v17.12.4"
tagdir="${tag}.jj"
trunk="master"
trunkdir="${trunk}.jj"

main() {
    local curdir=$(pwd)

    jj::clone
    jj::workspace
    go::path
    plz::bootstrap

    echo "alias plz=${curdir}/${tagdir}/plz-out/bin/src/please"
}

jj::clone() {
    if [ ! -d ${trunkdir} ]; then
	jj git clone ${repo} ${trunkdir}
    fi
}

jj::workspace() {
    if [ ! -d ${tagdir} ]; then
	jj -R ${trunkdir} workspace add --name ${tag} -r ${tag} ${tagdir}
    fi
}

go::path() {
    local gobin
    local goversion=$(awk '$1 == "go" { sub("\\.", "", $2); print($2) }' ${tagdir}/go.mod)

    if [ -z "${goversion}" ]; then
	error "no go version found in ${tagdir}/go.mod"
    fi

    gobin="/usr/local/go${goversion}/bin/go"
    if [ ! -x "${gobin}" ]; then
	error "no file ${gobin}"
    fi

    export PATH=$(dirname ${gobin}):${PATH}
}

plz::bootstrap() {
    cd ${tag}.jj
    ./bootstrap.sh --skip_tests
}

error() {
    local message="${1}"
    echo "E: ${message}" 1>&2
    exit 1
}

main "${@}"
