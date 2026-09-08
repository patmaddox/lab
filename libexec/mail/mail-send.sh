#!/bin/sh
#
# mail-send.sh -- send a patch series to the mailing list maildir.
#
# A thin wrapper around git send-email(1) that uses maildir-deliver.sh
# as the delivery backend (--sendmail-cmd), so a branch's commits are
# formatted as patch emails and filed into the maildir instead of being
# sent over SMTP.  git is the transport: commit the maildir and push.
#
# This is only for turning commits into a patch series.  Composed mail
# (a notmuch reply) does not need it -- message-mode delivers straight
# through maildir-deliver.sh.
#
# All arguments are forwarded to git send-email, so the usual revision
# ranges, files, and flags work:
#
#     mail-send.sh trunk..my-branch            # a series
#     mail-send.sh --cover-letter -3 HEAD      # with a cover letter
#     mail-send.sh /tmp/patches/*.patch        # pre-formatted patches
#
# The From address is enforced and the destination maildir is resolved
# by maildir-deliver.sh (${MAILDIR} or notmuch config).  --suppress-cc
# keeps git send-email from adding the author as a Cc.

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
	local libdir
	libdir="$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd)" \
	    || die "cannot resolve script directory"

	git send-email \
	    --sendmail-cmd="${libdir}/maildir-deliver.sh" \
	    --suppress-cc=all \
	    --confirm=never \
	    --no-validate \
	    --quiet \
	    "${@}"
}

main "${@}"
