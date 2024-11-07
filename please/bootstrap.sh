#!/bin/sh
set -eu

repo="https://github.com/thought-machine/please.git"
tag="v17.12.4"
main="master"
maindir="${main}.jj"

main() {
    jj::clone
    jj::workspace
}

jj::clone() {
    if [ ! -d ${maindir} ]; then
	jj --ignore-immutable git clone ${repo} ${maindir}
    fi
}

jj::workspace() {
    local jjdir="${tag}.jj"

    if [ ! -d ${jjdir} ]; then
	jj -R ${maindir} workspace add --name ${tag} -r ${tag} ${jjdir}
    fi
}

main "${@}"
