#!/bin/sh
set -eu
set -o pipefail

main() {
    resize-gpt
    bootstrap-poudriere
    touch /var/bootstrap.done
}

resize-gpt() {
    gpart recover ada0
    gpart resize -i 2 ada0

    gpart recover ada1
    gpart resize -i 1 ada1

    # zdata does not attach when booted with a new image
    # might be able to find a way to configure that
    if ! zpool list zdata > /dev/null 2>&1; then
	zpool import zdata
    fi
    # should not need to online -e this
    # but it doesn't autoexpand for some reason
    zpool online -e zdata ada1p1
}

bootstrap-poudriere() {
    if ! which poudriere > /dev/null; then
	make -C lab.jj/src/freebsd-ports/main.jj/ports-mgmt/poudriere-devel \
	     -D BATCH \
	     -s \
	     install \
	     DISTDIR=/tmp/ports/dist \
	     PORTSDIR=/root/lab.jj/src/freebsd-ports/main.jj \
	     WRKDIRPREFIX=/tmp/ports/work install
    fi

    set +o pipefail
    if ! poudriere ports -l -n | grep -q '^default$'; then
	poudriere ports -c -m null -M /root/lab.jj/src/freebsd-ports/main.jj
    fi
    set -o pipefail

    if ! poudriere jail -i -j 142 > /dev/null 2>&1; then
	poudriere jail -c -j 142 -m url=file:///root/lab.jj/ninja-out/freebsd-src/14.2-RELEASE -K GENERIC -v 14.2
    fi

    if ! poudriere jail -i -j 143 > /dev/null 2>&1; then
	poudriere jail -c -j 143 -m url=file:///root/lab.jj/ninja-out/freebsd-src/14.2-STABLE -K GENERIC -v 14.3
    fi

    local stabweek
    if ! poudriere jail -i -j 150 > /dev/null 2>&1; then
	stabweek=$(cd lab.jj/ninja-out/freebsd-src && ls -r -d 15.0-STABWEEK-* | head -n 1)
	poudriere jail -c -j 150 -m url=file:///root/lab.jj/ninja-out/freebsd-src/${stabweek} -K GENERIC -v 15.0
    fi
}

main
