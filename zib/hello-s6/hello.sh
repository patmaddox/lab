#!/bin/sh
set -eu
set -o pipefail

IFS= read name || :
name=${name:-world}

printf 'hello, %s!\n' "${name}"
