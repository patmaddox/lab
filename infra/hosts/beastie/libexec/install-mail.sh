#!/bin/sh
# Install Pat's mail client config for lab-mail from ../mail: the
# lab-mail notmuch profile's config, ~/.mbsyncrc, and ~/.msmtprc. Run
# it as Pat, as just install-mail. The repo holds the config, so an
# installed file that differs is replaced and kept as <file>.old.
#
# It also makes the mail root's sent folder, which mbsync never syncs,
# and an empty password file for Pat to fill in. It never changes a
# password file that exists.
set -eu

src="$(dirname "$(realpath "$0")")/../mail"
root="${HOME}/mail/pat@p7x.dev"
pwdir="${HOME}/.config/lab-mail"
pwfile="${pwdir}/password"

install -d "${HOME}/.config/notmuch/lab-mail"
install -b -C -m 0644 "${src}/notmuch-config" \
    "${HOME}/.config/notmuch/lab-mail/config"
install -b -C -m 0600 "${src}/mbsyncrc" "${HOME}/.mbsyncrc"
install -b -C -m 0600 "${src}/msmtprc" "${HOME}/.msmtprc"

install -d "${root}/sent/cur" "${root}/sent/new" "${root}/sent/tmp"

install -d -m 0700 "${pwdir}"
if [ ! -e "${pwfile}" ]; then
	install -m 0600 /dev/null "${pwfile}"
	echo "Write the password of pat@p7x.dev on lab-mail into ${pwfile}"
fi
