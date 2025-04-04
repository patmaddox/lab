#!/bin/sh

bindir=$(dirname $(realpath $0))
configs=$(ls config/*.conf)

cat ${bindir}/ninja.rules

cat <<EOF

# auto-generated from config/*.conf
EOF

for c in ${configs}; do
    c=$(basename ${c} .conf)

    cat <<EOF

## ${c}

build _build/${c}.build: build-freebsd | config/${c}.conf scripts/build.sh
  config = ${c}
build ${c}: phony _build/${c}.build

build _build/${c}.release: release-freebsd | _build/${c}.build
  config = ${c}
build ${c}/txz: phony _build/${c}.release
EOF
done
