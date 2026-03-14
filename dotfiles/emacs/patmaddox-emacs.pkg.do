#!/bin/sh
set -eu

# Build a FreeBSD package from emacs config files
# Install with: INSTALL_AS_USER=yes pkg -r ~ add patmaddox-emacs.pkg
# Files go to: ~/.emacs.d/

name="patmaddox-emacs"
version="0.0.0"
prefix="/.emacs.d"
srcdir="."

elfiles="init.el $(jj file list lisp contrib)"
redo-ifchange ${elfiles}

# Stage files
stagedir=$(mktemp -d)
trap "rm -rf ${stagedir}" EXIT

for f in ${elfiles}; do
    relpath="${f#${srcdir}/}"
    destdir="${stagedir}${prefix}/$(dirname "$relpath")"
    destfile="${destdir}/$(basename "$relpath")"
    mkdir -p "${destdir}"
    cp "$f" "${destfile}"
    chmod a-w "${destfile}"
done

# Calculate flatsize
flatsize=$(find "${stagedir}" -type f -exec stat -f%z {} + | awk '{s+=$1} END {print s}')

# Build files list for manifest
fileslist=""
for f in ${elfiles}; do
    relpath="${f#${srcdir}/}"
    fileslist="${fileslist}  ${prefix}/${relpath}: \"-\"
"
done

# Create manifest
manifest="${stagedir}/+MANIFEST"
cat > "${manifest}" <<EOF
name: ${name}
version: ${version}
origin: local/${name}
comment: Pat Maddox's Emacs configuration
maintainer: pat@patmaddox.com
prefix: ${prefix}
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/dotfiles/emacs
flatsize: ${flatsize}
desc: <<EOD
Emacs configuration files for Pat Maddox.

INSTALL_AS_USER=yes pkg -r ~ install -U \$(realpath ${name}.pkg)
EOD
files: {
${fileslist}}
EOF

pkg create -M "${manifest}" -r "${stagedir}" -o "$(dirname "$3")"
mv "$(dirname "$3")/${name}-${version}.pkg" "$3"
