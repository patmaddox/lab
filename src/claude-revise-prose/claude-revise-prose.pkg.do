#!/bin/sh
set -eu

# Build package claude-revise-prose, which installs the revise-prose
# skill and the prose-editor agent where Claude Code reads managed
# skills and agents, so every session on the host has them. Claude
# Code reads them only from /etc/claude-code, which yolo-coding-agent
# links to /usr/local/etc/claude-code.
#
# Its version is the time it was built, so each build is an upgrade.
# redo rebuilds it only when a file of the skill or agent changes.

readonly name=claude-revise-prose
readonly skilldir=/usr/local/etc/claude-code/.claude/skills/revise-prose
readonly agentdir=/usr/local/etc/claude-code/.claude/agents
version=$(date -u +%Y.%m.%d.%H%M%S)
readonly version

files=$(find skill -type f | sort)
agents=$(find agent -type f | sort)
redo-ifchange ${files} ${agents}

stagedir=$(mktemp -d)
metadir=$(mktemp -d)
trap "rm -rf ${stagedir} ${metadir}" EXIT

# The plist names each file, and each directory of the skill's own,
# so pkg removes them when it removes the package. The directories
# above the skill's own belong to whatever else installs managed
# settings, such as yolo-coding-agent. Other packages may install
# agents too, so each lists the agents directory, and pkg removes it
# once it is empty.
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
	mkdir -p ${stagedir}${agentdir}
	for f in ${agents}; do
		install -m 0644 ${f} ${stagedir}${agentdir}/${f#agent/}
		echo ${agentdir}/${f#agent/}
	done
	echo "@dir(root,wheel,0755) ${agentdir}"
} > ${metadir}/pkg-plist

cat > ${metadir}/+MANIFEST <<EOM
name: ${name}
version: "${version}"
origin: local/${name}
comment: "Claude Code skill and agent to place prose once"
maintainer: pat@patmaddox.com
prefix: /
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/src/${name}
desc: <<EOD
The revise-prose skill and prose-editor agent for Claude Code,
installed as managed ones. The skill decides whether an idea belongs
in a commit message, the docs, or a comment, so each is written once.
The agent reconciles a series of commits by it. See
src/${name}/README.md.
EOD
deps: {
  claude-code: { origin: "misc/claude-code", version: "0" }
}
EOM

pkg create -m ${metadir} -p ${metadir}/pkg-plist -r ${stagedir} -o ${metadir}
mv ${metadir}/${name}-${version}.pkg ${3}
