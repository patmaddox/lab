#!/bin/sh
set -eu

main() {
    local cmd remote
    cmd=${1}; shift

    cmd::${cmd} "${@}"
}

cmd::clone() {
    if [ -d freebsd-src.jj ]; then
	echo "E: freebsd-src is already cloned" 1>2
    else
	local version
	version=${1}
	remote=$(realpath $(plz query reporoot)/repos/freebsd-src.jj)
	jj -R ${remote} workspace forget __plz-dev 2> /dev/null || true
	jj -R ${remote} workspace add -r ${version} --name __plz-dev freebsd-src.jj
    fi
}

cmd::buildworld() {
    clean_env make -s \
	      -C freebsd-src.jj \
	      -j $(sysctl -n hw.ncpu) \
	      -D NO_ROOT \
	      SRCCONF=$(realpath ${SRCS_SRCCONF}) \
	      TZ=UTC \
	      __MAKE_CONF=/dev/null \
	      buildworld
}

clean_env() {
    env -i PATH=${PATH} "$@"
}

main "${@}"
