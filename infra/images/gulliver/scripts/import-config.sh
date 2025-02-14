#!/bin/sh
set -eu
set -o pipefail

main() {
    FILES="${@}"

    validate_files
    import_config
}

validate_files() {
    local f
    for f in ${FILES}; do
	realpath ${f} > /dev/null
    done
}

import_config() {
    local f mtree
    for f in ${FILES}; do
	mtree=$(realpath ${f})
	doas tar -C / -c @${mtree} | tar -C $(dirname ${mtree}) -x
    done
}

main "${@}"
