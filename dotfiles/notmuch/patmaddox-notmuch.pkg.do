#!/bin/sh
set -eu

# Build a FreeBSD package of the notmuch hooks and sample configs
# Install with: INSTALL_AS_USER=yes pkg -r ~ add patmaddox-notmuch.pkg
# Files go to: ~/.config/notmuch/default/, notmuch's default hook dir,
# and ~/.config/notmuch/lab-mail/, the lab-mail profile's

name="patmaddox-notmuch"
version="0.0.0"
prefix="/.config/notmuch"
sample="${prefix}/default/notmuch-config.sample"
config="/.notmuch-config"

default_files="$(jj file list hooks) notmuch-config.sample"
labmail_files="$(jj file list lab-mail)"
redo-ifchange ${default_files} ${labmail_files}

# Stage files
stagedir=$(mktemp -d)
trap "rm -rf ${stagedir}" EXIT

fileslist=""

# stage <source> <path under the prefix>
stage() {
    mkdir -p "${stagedir}${prefix}/$(dirname "$2")"
    cp "$1" "${stagedir}${prefix}/$2"
    # A sample stays writable, since the config copied from it keeps
    # its mode.
    case "$1" in
    *.sample) ;;
    *) chmod a-w "${stagedir}${prefix}/$2" ;;
    esac
    fileslist="${fileslist}  ${prefix}/$2: \"-\"
"
}

for f in ${default_files}; do
    stage "$f" "default/$f"
done
for f in ${labmail_files}; do
    stage "$f" "$f"
done

flatsize=$(find "${stagedir}" -type f -exec stat -f%z {} + | awk '{s+=$1} END {print s}')

# Each sample becomes its config only if none exists, and is removed
# on deinstall only if still unedited, like the ports @sample keyword.
# pkg resolves these paths against the install root.
manifest="${stagedir}/+MANIFEST"
cat > "${manifest}" <<EOM
name: ${name}
version: ${version}
origin: local/${name}
comment: notmuch hooks and configs for the lab-devel list
maintainer: pat@patmaddox.com
prefix: ${prefix}
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/dotfiles/notmuch
flatsize: ${flatsize}
desc: <<EOD
notmuch hooks for the lab-devel list, installed in each profile's
default hook dir so no hook_dir setting is needed: the default
profile, which reads the jj maildir, and the lab-mail profile, which
reads the list synced from lab-mail. The default profile's sample
config is installed if it has none. The lab-mail profile's sample is
installed beside its hooks, for each host to copy and fill in.

INSTALL_AS_USER=yes pkg -r ~ install -U \$(realpath ${name}.pkg)
EOD
files: {
${fileslist}}
lua_scripts: {
  post-install: [ <<EOS
if not pkg.stat("${config}") then
  pkg.copy("${sample}", "${config}")
end
EOS
  ]
  pre-deinstall: [ <<EOS
if pkg.filecmp("${sample}", "${config}") == 0 then
  os.remove("${config}")
end
EOS
  ]
}
EOM

pkg create -M "${manifest}" -r "${stagedir}" -o "$(dirname "$3")"
mv "$(dirname "$3")/${name}-${version}.pkg" "$3"
