#!/bin/sh
set -eu
set -o pipefail

bindir=$(dirname $(realpath $0))
configs=$(ls config/*.conf)
release_files="MANIFEST base.txz kernel.txz src.txz tests.txz"
src_root="src/freebsd-src"

config_builds=""
config_releases=""

for c in ${configs}; do
    c=$(basename ${c} .conf)
    config_builds="mod.freebsd.build.${c} ${config_builds}"
    config_releases="mod.freebsd.release.${c} ${config_releases}"
done

cat ${bindir}/ninja.rules

cat <<EOF

# auto-generated from config/*.conf

#build mod.freebsd.build: phony ${config_builds}
#build freebsd.build: phony mod.freebsd.build

build mod.freebsd.release: phony ${config_releases}
#build freebsd.release: phony mod.freebsd.release
build freebsd.all: phony mod.freebsd.release

EOF

for c in ${configs}; do
    c=$(basename ${c} .conf)
    c_release_dir=${src_root}/_build/${c}/amd64.amd64/release
    c_release_files=$(echo ${release_files} | sed -e "s|^|${c_release_dir}/|" -e "s|[[:space:]+]| ${c_release_dir}/|g")
    c_release_ninja_dir=ninja-out/freebsd-src/${c}
    c_release_ninja_files=$(echo ${release_files} | sed -e "s|^|${c_release_ninja_dir}/|" -e "s|[[:space:]+]| ${c_release_ninja_dir}/|g")

    cat <<EOF

## ${c}

build ${src_root}/_build/${c}.build: build-freebsd | ${src_root}/config/${c}.conf ${src_root}/scripts/build.sh
  config = ${c}
build mod.freebsd.build.${c}: phony ${src_root}/_build/${c}.build
#build freebsd.build.${c}: phony mod.freebsd.build.${c}

build ${c_release_ninja_files}: release-freebsd | mod.freebsd.build.${c}
  config = ${c}
build mod.freebsd.release.${c}: phony ${c_release_ninja_files}
#build freebsd.release.${c}: phony mod.freebsd.release.${c}
build freebsd.${c}: phony mod.freebsd.release.${c}
EOF
done
