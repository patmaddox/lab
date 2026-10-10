#!/bin/sh
#
# am.sh -- git am for a jj workspace, with or without a git repo.
#
#     am.sh <workspace>
#
# Reads one message or an mbox of patches on stdin and applies them with
# git am on top of the parent of @ in the jj workspace at <workspace>,
# then moves that workspace onto the result.  The workspace needs no
# .git, so it works in ~/lab/mail.jj as well as ~/lab/default.jj.  It is
# run as `just am`, which notmuch can pipe a message into.
#
# git am runs in a temporary git worktree of the repo's git backend,
# checked out on a temporary branch, so that jj can import the commits
# it makes.  The worktree and the branch are removed however am.sh
# exits, and the workspace's new @ keeps the patches visible.
#
# Messages without a diff, such as a cover letter or a review reply, are
# dropped, so a whole series thread can be piped at once.
#
# @ must be empty, the way git am wants a clean tree.  If any patch
# fails to apply, nothing is applied and the workspace is unchanged.

set -eu
set -o pipefail

readonly PROGNAME="${0##*/}"

err() {
	echo "${PROGNAME}: ${*}" >&2
}

die() {
	err "${@}"
	exit 1
}

gitdir=""
tmp=""
branch=""

cleanup() {
	git --git-dir="${gitdir}" worktree remove --force "${tmp}/wt" \
	    >/dev/null 2>&1 || true
	git --git-dir="${gitdir}" branch -D "${branch}" >/dev/null 2>&1 ||
	    true
	# The branch is gone, but the patches must stay: jj would abandon
	# them, and their base, as commits no ref reaches any more.
	jj --config git.abandon-unreachable-commits=false git import \
	    --quiet || true
	rm -rf "${tmp}"
}

main() {
	local base head

	[ "${#}" -eq 1 ] || die "usage: ${PROGNAME} <workspace>"
	[ -d "${1}" ] || die "${1}: no such directory"
	cd "${1}"

	[ "$(jj log --no-graph -r @ -T empty)" = true ] ||
	    die "@ is not empty; run jj new first"
	base="$(jj log --no-graph -r @- -T 'commit_id ++ "\n"')"
	[ "$(echo "${base}" | wc -l)" -eq 1 ] ||
	    die "@ has more than one parent"

	gitdir="$(jj git root)"
	tmp="$(mktemp -d "${TMPDIR:-/tmp}/am.XXXXXX")"
	branch="${tmp##*/}"
	trap cleanup EXIT

	git --git-dir="${gitdir}" worktree add --quiet -b "${branch}" \
	    "${tmp}/wt" "${base}"
	git -C "${tmp}/wt" -c advice.mergeConflict=false \
	    -c advice.amWorkDir=false am --quiet --empty=drop ||
	    die "patches do not apply; nothing changed"
	head="$(git -C "${tmp}/wt" rev-parse HEAD)"
	[ "${head}" != "${base}" ] || die "no patches on stdin"

	jj git import --quiet
	jj new --quiet "${head}"
}

main "${@}"
