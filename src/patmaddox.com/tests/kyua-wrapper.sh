#!/bin/sh
set -eu

main() {
    if [ $# -gt 0 ]; then
	kyua debug --kyuafile=${KYUAFILE} ${@}
    else
	kyua test --kyuafile=${KYUAFILE}
    fi
}

main "${@}"
