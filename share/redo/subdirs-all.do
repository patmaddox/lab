#!/bin/sh
set -eu
set -o pipefail

# symlink this to all.do in any dir that should build subdirs
files=$(ls */all.do 2>/dev/null || true)
if [ -n "${files}" ]; then redo-ifchange ${files%.do}; fi
