#!/bin/sh
set -eu

# Build package claude-repo-docs, which installs the repo-docs skill
# where Claude Code reads managed skills, so every session on the host
# has it. Claude Code reads them only from /etc/claude-code, which
# yolo-coding-agent links to /usr/local/etc/claude-code. On another
# host, make that link before installing.
#
# Its version is the time it was built, so each build is an upgrade.
# redo rebuilds it only when a file of the skill changes.

readonly name=claude-repo-docs
readonly skilldir=/usr/local/etc/claude-code/.claude/skills/repo-docs
version=$(date -u +%Y.%m.%d.%H%M%S)
readonly version

files=$(find skill -type f | sort)
redo-ifchange ${files}

stagedir=$(mktemp -d)
metadir=$(mktemp -d)
trap "rm -rf ${stagedir} ${metadir}" EXIT

# The plist names each file, and each directory of the skill's own,
# so pkg removes them when it removes the package. The directories
# above the skill's own belong to whatever else installs managed
# settings, such as yolo-coding-agent.
{
	echo '@mode 0644'
	for f in ${files}; do
		mkdir -p $(dirname ${stagedir}${skilldir}/${f#skill/})
		install -m 0644 ${f} ${stagedir}${skilldir}/${f#skill/}
		echo ${skilldir}/${f#skill/}
	done
	find skill -type d | sort -r | while read -r d; do
		echo "@dir(root,wheel,0755) ${skilldir}${d#skill}"
	done
} > ${metadir}/pkg-plist

cat > ${metadir}/+MANIFEST <<EOM
name: ${name}
version: "${version}"
origin: local/${name}
comment: "Claude Code skill to write and revise a repo's documentation"
maintainer: pat@patmaddox.com
prefix: /
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/src/${name}
desc: <<EOD
The repo-docs skill for Claude Code, installed as a managed skill.
It writes and revises code comments and a repository's docs,
following Diataxis per section. See src/${name}/README.md.
EOD
deps: {
  claude-code: { origin: "misc/claude-code", version: "0" }
}
EOM

pkg create -m ${metadir} -p ${metadir}/pkg-plist -r ${stagedir} -o ${metadir}
mv ${metadir}/${name}-${version}.pkg ${3}
