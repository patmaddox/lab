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

build _build/stamps/build/${c}: build-freebsd
build ${c}: phony _build/stamps/build/${c}

build _build/stamps/release/${c}: release-freebsd | _build/stamps/build/${c}
build ${c}/txz: phony _build/stamps/release/${c}
EOF
done
