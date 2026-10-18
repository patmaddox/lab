#!/bin/sh
#
# mail-tag.sh -- derive notmuch tags from the list synced from lab-mail.
#
# Every tag here is recomputed from the mail root on every run, so the
# database holds no state of its own: rebuild it from the mail root and
# the same tags come back.
#
#   sent: from the user (notmuch user.primary_email or other_email)
#   replied: from someone else, and the user has replied to it
#   inbox: from someone else, in INBOX, and not replied to
#   next: in Next
#   later: in Later
#   archived: in Archive
#
# "Replied to" means a message from the user names it in In-Reply-To.
# Drafts get none of these tags.
#
# replied is mirrored to the maildir R flag when synchronize_flags is
# on, so a change to it renames the message's file. It is therefore
# changed only where it is wrong, never cleared and set again.
#
# Runs from the notmuch post-new hook, so notmuch new applies it.

set -eu
set -o pipefail

readonly drafts='path:drafts/**'

tmp=""

main() {
	local me
	me="$(me_query)"
	tmp="$(mktemp -d)"
	trap 'rm -rf "${tmp}"' EXIT

	replied_changes "${me}" | notmuch tag --batch

	{
		echo "-sent -inbox -next -later -archived -- ${drafts}"
		echo "+sent -inbox -- (${me}) and not ${drafts}"
		echo "-sent -- not (${me}) and not ${drafts}"
		echo "+inbox -- folder:INBOX and not tag:replied" \
		    "and not (${me}) and not ${drafts}"
		echo "-inbox -- not folder:INBOX or tag:replied"
		echo "+next -- folder:Next and not ${drafts}"
		echo "-next -- not folder:Next"
		echo "+later -- folder:Later and not ${drafts}"
		echo "-later -- not folder:Later"
		echo "+archived -- folder:Archive and not ${drafts}"
		echo "-archived -- not folder:Archive"
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

# Tag batch lines that add replied where the user has replied and
# remove it where they have not, touching no message already right.
replied_changes() {
	local me id
	me="${1}"

	notmuch search --output=messages "tag:replied" |
	    sed -e 's/^id://' | sort -u > "${tmp}/have"
	replied_ids "${me}" > "${tmp}/want"

	comm -13 "${tmp}/have" "${tmp}/want" | while read -r id; do
		echo "+replied -- id:\"${id}\" and not (${me}) and not ${drafts}"
	done
	comm -23 "${tmp}/have" "${tmp}/want" | while read -r id; do
		echo "-replied -- id:\"${id}\""
	done
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
