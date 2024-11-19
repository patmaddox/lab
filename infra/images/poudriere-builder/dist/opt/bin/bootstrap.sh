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
}

bootstrap-poudriere() {
    for p in ports-mgmt/pkg ports-mgmt/poudriere-devel; do
	cd /usr/ports/${p}
	make -D BATCH install
    done
}

main
