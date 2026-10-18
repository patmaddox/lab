#!/bin/sh
# Check Pat's mail client for lab-mail on beastie, before he switches
# to it: the ports it needs, the configs from ../mail, the password
# file, and the mail root. Then run the check of dotfiles/notmuch,
# which logs in to lab-mail, makes a dry run of the sync, and reaches
# msmtp. Run it as Pat, as just check-mail. Prints one line per check
# and exits 1 if any fails. It only reads, and posts no mail.
set -u

here="$(dirname "$(realpath "$0")")"
src="${here}/../mail"
client_check="${here}/../../../../dotfiles/notmuch/check"
pwfile="${HOME}/.config/lab-mail/password"

failed=0

# check <what> <command> [args]: run the command, and report what was
# checked by its exit status.
check() {
	local what="${1}"; shift
	if "${@}" >/dev/null 2>&1; then
		echo "ok ${what}"
	else
		echo "FAIL ${what}"
		failed=1
	fi
}

# same_as <file in ../mail> <installed file>
same_as() {
	cmp -s "${src}/${1}" "${2}"
}

only_pat_reads() {
	[ "$(stat -f %Lp "${1}")" = 600 ]
}

main() {
	check "isync is installed" pkg info -e isync
	check "msmtp is installed" pkg info -e msmtp
	check "notmuch is installed" pkg info -e notmuch
	check "the lab-mail profile's config is beastie's" \
	    same_as notmuch-config "${HOME}/.config/notmuch/lab-mail/config"
	check "~/.mbsyncrc is beastie's" same_as mbsyncrc "${HOME}/.mbsyncrc"
	check "~/.msmtprc is beastie's" same_as msmtprc "${HOME}/.msmtprc"
	check "the password file is not empty" test -s "${pwfile}"
	check "only Pat can read the password file" only_pat_reads "${pwfile}"
	check "the sent folder exists" test -d "${HOME}/mail/pat@p7x.dev/sent/cur"
	"${client_check}" || failed=1
	exit "${failed}"
}

main "${@}"
