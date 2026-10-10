#!/bin/sh
#
# format-patch.sh -- git format-patch, carrying each commit's change id.
#
# All arguments are passed to git format-patch(1), which must write
# files (not --stdout).  Each patch it writes then gets the change id
# of its commit twice:
#
#   - a Change-Id header beside From, Date, and Subject, for tools
#   - a "change-id:" line under the "---", for readers
#
# Both are dropped by git am, so neither ends up in the applied commit.
# The change id survives rewrites, so it ties the versions of a patch
# together across a revised series.  The cover letter carries none.
#
# The id comes from the commit's change-id header, which jj, GitButler,
# and Gerrit agreed on and jj writes by default, so commits from any of
# them work.  jj is asked only for a commit without the header.
#
# Pass --base=<trunk commit> so git adds base-commit and, for a series
# on unmerged work, prerequisite-patch-id lines:
#
#     format-patch.sh -o /tmp/series --base="${base}" "${base}..${head}"

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

main() {
	local arg file

	# git lists the files it writes, unless told to be quiet.
	for arg; do
		shift
		case "${arg}" in
		-q|--quiet) ;;
		*) set -- "${@}" "${arg}" ;;
		esac
	done

	git format-patch "${@}" | while read -r file; do
		add_change_id "${file}"
		echo "${file}"
	done
}

# Add the change id of the commit a patch file was made from.  git
# format-patch names that commit on the file's first line, the mbox
# "From <sha>" separator.  The cover letter is no commit's patch.
add_change_id() {
	local file sha cid
	file="${1}"

	case "${file}" in
	*-cover-letter.patch) return 0 ;;
	esac

	sha="$(sed -n '1s/^From \([0-9a-f]\{40\}\) .*/\1/p' "${file}")"
	[ -n "${sha}" ] || die "${file}: no commit on first line"

	cid="$(git cat-file commit "${sha}" |
	    sed -n '/^$/q; s/^change-id //p')"
	[ -n "${cid}" ] || cid="$(jj log --no-graph -r "${sha}" -T change_id)"
	[ -n "${cid}" ] || die "${file}: no change id for ${sha}"

	awk -v cid="${cid}" '
		!done_header && /^$/ { print "Change-Id: " cid; done_header = 1 }
		{ print }
		done_header && !done_notes && /^---$/ {
			print "change-id: " cid
			print ""
			done_notes = 1
		}
	' "${file}" >"${file}.tmp"
	mv "${file}.tmp" "${file}"
}

main "${@}"
