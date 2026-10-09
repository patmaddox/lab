#!/bin/sh
set -eu
set -o pipefail

redo-always

printf '%s {\n}\n' "$(./jailname.sh)"