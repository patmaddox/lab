#!/bin/sh
#
# mail-tag.sh -- derive notmuch tags from the contents of the list.
#
# The sent, inbox and replied tags are recomputed from the messages on
# every run, so the database holds no state of its own: rebuild it from
# the maildir and the same tags come back.
#
#   sent     from the user (notmuch user.primary_email or other_email)
#   inbox    from someone else, and the user has not replied to it
#   replied  from someone else, and the user has replied to it
#
# "Replied to" means a message from the user names it in In-Reply-To.
# Drafts get none of these tags.
#
# Runs from the notmuch post-new hook, so notmuch new applies it.

set -eu
set -o pipefail

readonly drafts='path:drafts/**'

main() {
	local me id
	me="$(me_query)"

	{
		echo "-sent -inbox -replied -- ${drafts}"
		echo "+sent -inbox -replied -- (${me}) and not ${drafts}"
		echo "-sent +inbox -replied -- not (${me}) and not ${drafts}"
		replied_ids "${me}" | while read -r id; do
			echo "+replied -inbox -- id:\"${id}\" and not (${me}) and not ${drafts}"
		done
	} | notmuch tag --batch
}

# A query matching mail from any of the user's addresses.
me_query() {
	local addrs
	addrs="$(notmuch config get user.primary_email)
$(notmuch config get user.other_email 2>/dev/null | tr ';' '\n')"
	printf '%s\n' "${addrs}" | awk '
		NF { q = q (q == "" ? "" : " or ") "from:\"" $0 "\"" }
		END {
			if (q == "") exit 1
			print q
		}
	' || die "no user address: set notmuch user.primary_email"
}

# Message-IDs the user has replied to, from In-Reply-To of their mail.
replied_ids() {
	notmuch search --output=files --format=text0 \
	    "(${1}) and not ${drafts}" |
	    xargs -0 -r awk '
		FNR == 1 { in_header = 1; irt = 0 }
		!in_header { next }
		/^$/ { in_header = 0; next }
		tolower($0) ~ /^in-reply-to:/ { irt = 1; grab($0); next }
		irt && /^[ \t]/ { grab($0); next }
		{ irt = 0 }
		function grab(s) {
			if (match(s, /<[^>]+>/)) {
				print substr(s, RSTART + 1, RLENGTH - 2)
				irt = 0
			}
		}
	' | sort -u
}

die() {
	echo "${0##*/}: ${*}" >&2
	exit 1
}

main "${@}"
