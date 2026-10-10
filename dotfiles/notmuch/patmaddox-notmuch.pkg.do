#!/bin/sh
set -eu

# Build a FreeBSD package of the notmuch hooks
# Install with: INSTALL_AS_USER=yes pkg -r ~ add patmaddox-notmuch.pkg
# Files go to: ~/.config/notmuch/default/, notmuch's default hook dir

name="patmaddox-notmuch"
version="0.0.0"
prefix="/.config/notmuch/default"

files="$(jj file list hooks)"
redo-ifchange ${files}

# Stage files
stagedir=$(mktemp -d)
trap "rm -rf ${stagedir}" EXIT

fileslist=""
for f in ${files}; do
    mkdir -p "${stagedir}${prefix}/$(dirname "$f")"
    cp "$f" "${stagedir}${prefix}/$f"
    chmod a-w "${stagedir}${prefix}/$f"
    fileslist="${fileslist}  ${prefix}/${f}: \"-\"
"
done

flatsize=$(find "${stagedir}" -type f -exec stat -f%z {} + | awk '{s+=$1} END {print s}')

manifest="${stagedir}/+MANIFEST"
cat > "${manifest}" <<EOM
name: ${name}
version: ${version}
origin: local/${name}
comment: notmuch hooks for the lab-devel list
maintainer: pat@patmaddox.com
prefix: ${prefix}
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/dotfiles/notmuch
flatsize: ${flatsize}
desc: <<EOD
notmuch hooks for the lab-devel list, installed in notmuch's default
hook dir so no hook_dir setting is needed.

INSTALL_AS_USER=yes pkg -r ~ install -U \$(realpath ${name}.pkg)
EOD
files: {
${fileslist}}
EOM

pkg create -M "${manifest}" -r "${stagedir}" -o "$(dirname "$3")"
mv "$(dirname "$3")/${name}-${version}.pkg" "$3"
