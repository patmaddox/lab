#!/bin/sh
set -eu
set -o pipefail

mkdir -p tmp
trap 'rm -f tmp/poudriere.p7x.dev.*.pem' EXIT INT TERM HUP

acme.sh --install-cert -d p7x.dev \
	--key-file       tmp/poudriere.p7x.dev.key.pem  \
	--fullchain-file tmp/poudriere.p7x.dev.cert.pem

if openssl x509 -checkend 0 -noout -in tmp/poudriere.p7x.dev.cert.pem; then
    scp tmp/poudriere.p7x.dev.*.pem root@poudriere:/usr/local/etc/nginx/
    ssh root@poudriere "service nginx reload"
else
    echo "E: cert is expired" >&2
    exit 1
fi
