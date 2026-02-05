#!/bin/sh
# Signing script for pkg-repo with fingerprints support
# Receives SHA256 hash on stdin, outputs signed data

KEY=/usr/local/etc/ssl/poudriere.key
CERT=/usr/local/etc/ssl/poudriere.cert

# Read hash from stdin
read -t 2 sum
[ -z "$sum" ] && exit 1

# Output in required format
echo SIGNATURE
echo -n $sum | /usr/bin/openssl dgst -sign $KEY -sha256 -binary
echo
echo CERT
cat $CERT
echo END
