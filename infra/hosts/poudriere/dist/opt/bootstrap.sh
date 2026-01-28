#!/bin/sh
set -eu
set -o pipefail

main() {
    resize-gpt
    bootstrap-poudriere
    touch /var/bootstrap.done
}

resize-gpt() {
    gpart recover vtbd0
    gpart resize -i -2 vtbd0

    gpart recover vtbd1
    gpart resize -i -1 vtbd1

    # zdata does not attach when booted with a new image
    # might be able to find a way to configure that
    if ! zpool list zdata > /dev/null 2>&1; then
	zpool import zdata
    fi
    # should not need to online -e this
    # but it doesn't autoexpand for some reason
    zpool online -e zdata vtbd1p1
}

bootstrap-poudriere() {
    set +o pipefail
    # cat is a hack to avoid a SIGPIPE from grep exiting as soon as
    # it finds a match
    if ! poudriere ports -l -n | cat | grep -qx local; then
	poudriere ports -c -p local -m null -M /root/lab.jj/src/freebsd-ports/default.jj
    fi
    set -o pipefail

    if ! poudriere jail -i -j current > /dev/null 2>&1; then
	poudriere jail -c -j current -v 16 -K generic-nodebug \
		  -m pkgbase=latest \
		  -U file:///root/lab.jj/oss/freebsd-src/_build/current/pkgbase
    fi

    if ! poudriere jail -i -j 160 > /dev/null 2>&1; then
	poudriere jail -c -j 160 -v 16 -K generic-nodebug \
		  -m pkgbase=latest \
		  -U file:///root/lab.jj/oss/freebsd-src/_build/160/pkgbase
    fi

    if ! poudriere jail -i -j 150 > /dev/null 2>&1; then
	poudriere jail -c -j 150 -v 15 -K generic \
		  -m pkgbase=base_release_0 \
		  -U https://pkg.freebsd.org
    fi

    if ! poudriere jail -i -j 143 > /dev/null 2>&1; then
	poudriere jail -c -j 143 -v 14 -K generic \
		  -m pkgbase=base_release_3 \
		  -U https://pkg.freebsd.org
    fi
}

main
