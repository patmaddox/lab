#!/bin/sh
set -eu
set -o pipefail

IFS= read name || :

if [ -z "${name}" ]; then
	name=$(id -un "${IPCREMOTEEUID}")
fi

printf 'hello, %s!\n' "${name}"
