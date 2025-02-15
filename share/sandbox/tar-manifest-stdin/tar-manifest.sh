#!/bin/sh
set -eu
set -o pipefail

mkdir -p _build

echo "this is foo" > _build/foo
ls -l _build/foo
tar -C _build -cf _build/mytar.tar @- <<EOF
#mtree

foo mode=600 type=file
EOF

rm _build/foo
tar -C _build -xf _build/mytar.tar
ls -l _build/foo
