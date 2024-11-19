#!/bin/sh
set -eu

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

    # should not need to online -e this
    # but it doesn't autoexpand for some reason
    zpool import zdata
    zpool online -e zdata ada1p1
}

bootstrap-poudriere() {
    for p in ports-mgmt/pkg ports-mgmt/poudriere-devel; do
	cd /usr/ports/${p}
	make -D BATCH install
    done
}

main
