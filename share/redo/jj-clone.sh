# share/redo/jj-clone.sh
#
# Shared implementation for cloning a git repo with jj.
# Sourced by clone.do scripts that set:
#
#	repo_url	(required) git URL to clone
#
# Creates a colocated clone at default.jj in the current directory.
set -eu

if [ -z "${repo_url:-}" ]; then
	echo "error: repo_url not set" >&2
	exit 1
fi

if [ ! -d default.jj ]; then
	jj git clone --colocate "$repo_url" default.jj
fi
