#!/bin/sh
set -eu

# Build a FreeBSD package of lab-process-mail.
# Install with: INSTALL_AS_USER=yes pkg -r ~/local add lab-process-mail.pkg
# Files go to: bin/ and share/lab-process-mail/ under the root given to
# pkg -r, so the package carries no LOCALBASE of its own.

name="lab-process-mail"
version="0.0.0"
prefix="/"

redo-ifchange lab-process-mail prompt.md

# Stage files
stagedir=$(mktemp -d)
trap "rm -rf ${stagedir}" EXIT

mkdir -p "${stagedir}/bin" "${stagedir}/share/${name}"
install -m 0555 lab-process-mail "${stagedir}/bin/lab-process-mail"
install -m 0444 prompt.md "${stagedir}/share/${name}/prompt.md"

# Calculate flatsize
flatsize=$(find "${stagedir}" -type f -exec stat -f%z {} + | awk '{s+=$1} END {print s}')

# Create manifest
manifest="${stagedir}/+MANIFEST"
cat > "${manifest}" <<EOM
name: ${name}
version: ${version}
origin: local/${name}
comment: Answer the lab-devel inbox, one agent pass per message
maintainer: pat@patmaddox.com
prefix: ${prefix}
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/src/${name}
flatsize: ${flatsize}
desc: <<EOD
Answer the lab-devel inbox, one agent pass per message, oldest first.

INSTALL_AS_USER=yes pkg -r ~/local install -U \$(realpath ${name}.pkg)
EOD
files: {
  /bin/lab-process-mail: "-"
  /share/${name}/prompt.md: "-"
}
EOM

pkg create -M "${manifest}" -r "${stagedir}" -o "$(dirname "$3")"
mv "$(dirname "$3")/${name}-${version}.pkg" "$3"
