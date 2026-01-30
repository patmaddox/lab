#!/bin/sh
set -eu
set -o pipefail

# symlink this to clean.do in any dir that should build subdirs
files=$(ls -1 */clean.do 2>/dev/null | sed -e 's/\.do$//' || true)
if [ -n "${files}" ]; then redo ${files}; fi
