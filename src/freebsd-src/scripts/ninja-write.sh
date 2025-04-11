#!/bin/sh
set -eu
set -o pipefail

bindir=$(dirname $(realpath $0))
configs=$(ls config/*.conf)
release_files="MANIFEST base.txz kernel.txz src.txz tests.txz"
src_root="src/freebsd-src"

config_releases=""

for c in ${configs}; do
    c=$(basename ${c} .conf)
    config_releases="mod.freebsd.${c} ${config_releases}"
done

cat ${bindir}/ninja.rules

cat <<EOF

# auto-generated from config/*.conf

build mod.pkg.freebsd: phony ${config_releases}

EOF

for c in ${configs}; do
    c=$(basename ${c} .conf)
    c_release_dir=${src_root}/_build/${c}/amd64.amd64/release
    c_release_files=$(echo ${release_files} | sed -e "s|^|${c_release_dir}/|" -e "s|[[:space:]+]| ${c_release_dir}/|g")
    c_release_ninja_dir=ninja-out/freebsd-src/${c}
    c_release_ninja_files=$(echo ${release_files} | sed -e "s|^|${c_release_ninja_dir}/|" -e "s|[[:space:]+]| ${c_release_ninja_dir}/|g")

    cat <<EOF

## ${c}

build ${c_release_ninja_files}: build-freebsd | ${src_root}/config/${c}.conf ${src_root}/scripts/build.sh ${src_root}/src.conf
  config = ${c}
  stampfile = ${src_root}/_build/${c}.build
build mod.freebsd.${c}: phony ${c_release_ninja_files}
build freebsd.${c}: phony mod.freebsd.${c}
EOF
done
