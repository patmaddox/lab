#!/bin/sh

bindir=$(dirname $(realpath $0))
configs=$(ls config/*.conf)
release_files="MANIFEST base.txz kernel.txz src.txz tests.txz"

cat ${bindir}/ninja.rules

cat <<EOF

# auto-generated from config/*.conf
EOF

for c in ${configs}; do
    c=$(basename ${c} .conf)
    c_release_dir=_build/${c}/amd64.amd64/release
    c_release_files=$(echo ${release_files} | sed -e "s|^|${c_release_dir}/|" -e "s|[[:space:]+]| ${c_release_dir}/|g")
    c_release_ninja_dir=ninja-out/${c}
    c_release_ninja_files=$(echo ${release_files} | sed -e "s|^|${c_release_ninja_dir}/|" -e "s|[[:space:]+]| ${c_release_ninja_dir}/|g")

    cat <<EOF

## ${c}

build _build/${c}.build: build-freebsd | config/${c}.conf scripts/build.sh
  config = ${c}
build ${c}: phony _build/${c}.build

build ${c_release_ninja_files}: release-freebsd | _build/${c}.build
  config = ${c}
build ${c}/txz: phony ${c_release_ninja_files}
EOF
done
