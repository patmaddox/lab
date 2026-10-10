#!/bin/sh
#
# maildir-deliver.sh -- deliver a message into the mailing list maildir.
#
# A sendmail-compatible delivery agent.  A mail user agent pipes a fully
# formed message on stdin; recipient addresses and sendmail flags such
# as -i arrive as arguments and are ignored, because delivery is purely
# local.  message-mode and notmuch call this directly as their sendmail
# program -- a composed message already carries its own Message-ID, Date
# and threading headers, so nothing else is needed to put it in the
# maildir.  git format-patch output can be piped through it too; a
# leading mbox "From " separator line is dropped.
#
# The From header is kept as composed; the sender's mail config sets
# it.  A Date header is added if the message lacks one, so a message
# never lands undated (which sorts as the epoch).
#
# git is the transport: the message is only saved, not sent.  Commit it
# and push; notmuch new indexes it wherever the branch is checked out.
#
# The destination maildir is ${MAILDIR}, or the mail root notmuch is
# configured to index.  Delivery errors if neither is available.
#
# Deliver a composed message:
#
#     maildir-deliver.sh <message
#
# Deliver a patch series for review (one message per patch):
#
#     git format-patch --thread=shallow -o /tmp/p trunk..my-branch
#     for p in /tmp/p/*.patch; do maildir-deliver.sh <"${p}"; done

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
	local maildir name
	maildir="$(resolve_maildir)"
	mkdir -p "${maildir}/tmp" "${maildir}/cur" "${maildir}/new"

	# Write under tmp/ first and rename into cur/ so a reader never
	# sees a partial message.
	name="$(unique_name)"
	add_headers >"${maildir}/tmp/${name}"
	mv "${maildir}/tmp/${name}" "${maildir}/cur/${name}:2,"
}

# The maildir to deliver into: an explicit MAILDIR, else notmuch's
# configured mail root so delivery and indexing agree.  Error if neither
# is set rather than guessing.
resolve_maildir() {
	local root
	if [ -n "${MAILDIR:-}" ]; then
		printf '%s\n' "${MAILDIR}"
		return
	fi
	if command -v notmuch >/dev/null 2>&1; then
		root="$(notmuch config get database.mail_root 2>/dev/null || true)"
		[ -n "${root}" ] || \
		    root="$(notmuch config get database.path 2>/dev/null || true)"
		if [ -n "${root}" ]; then
			printf '%s\n' "${root}"
			return
		fi
	fi
	die "no maildir: set MAILDIR or configure notmuch database.mail_root"
}

# Add a Date if the message has none.  A leading mbox "From "
# separator is dropped.  in_header is true until the blank line that
# ends the headers.
add_headers() {
	awk -v date="$(date '+%a, %d %b %Y %H:%M:%S %z')" '
		BEGIN { in_header = 1 }
		NR == 1 && /^From / { next }			# mbox separator
		!in_header { print; next }			# body
		/^$/ {						# end of headers
			if (!date_done) print "Date: " date
			in_header = 0
			print
			next
		}
		{
			if (tolower($0) ~ /^date:/) date_done = 1
			print
		}
	'
}

# Generate a unique maildir filename: <time>.P<pid><rand>.<host>.
unique_name() {
	printf '%s.P%s%s.%s' \
	    "$(date +%s)" "$$" "$(rand)" "$(hostname -s 2>/dev/null || hostname)"
}

rand() {
	# Dependency-free alternative, if openssl is unavailable:
	#   od -An -N3 -tx1 /dev/urandom | tr -d ' \n'
	openssl rand -hex 3
}

main "${@}"
