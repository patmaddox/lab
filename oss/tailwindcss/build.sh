#!/bin/sh
# from dch: https://github.com/tailwindlabs/tailwindcss/discussions/7826#discussioncomment-4287014

set -eu
set -o pipefail

tree=${1}; shift
tree=$(realpath ${tree})

export TMPDIR=$(mktemp -d -t tailwind)
export NPM_CONFIG_CACHE=${TMPDIR}/.npm
export PKG_CACHE_PATH=${TMPDIR}/.pkg-cache

export CXXFLAGS='-I/usr/local/lib/gcc13/include/c++ -include cstdint'
export LDFLAGS='-Wl,-rpath=/usr/local/lib/gcc13'
export CC=/usr/local/bin/gcc13
export CXX=/usr/local/bin/g++13
export MAKE=/usr/local/bin/gmake
export LD=/usr/local/bin/ld
ln -s /usr/local/bin/python3.10 ${TMPDIR}/python3
export PATH=${TMPDIR}:$PATH

cd ${tree}
npm uninstall turbo
npm install @swc/core-freebsd-x64 --omit=dev
npm run prepublishOnly

cd ${tree}/standalone-cli
npm ci
./node_modules/.bin/pkg . \
    --target node16-freebsd-x64 \
    --compress Brotli \
    --no-bytecode \
    --public-packages "*" \
    --public
