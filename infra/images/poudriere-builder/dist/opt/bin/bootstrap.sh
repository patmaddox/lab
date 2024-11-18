#!/bin/sh
set -eu

main() {
    expand-zpool
    bootstrap-poudriere
    touch /var/bootstrap.done
}

expand-zpool() {
    zpool online -e zroot ada0p2
}

bootstrap-poudriere() {
    for p in ports-mgmt/pkg ports-mgmt/poudriere-devel; do
	cd /usr/ports/${p}
	make -D BATCH install
    done
}

main
