#!/bin/sh
# Install Pat's mail client config for lab-mail from ../mail: the
# lab-mail notmuch profile's config, ~/.mbsyncrc, and ~/.msmtprc. Run
# it as Pat, as just install-mail. The repo holds the config, so an
# installed file that differs is replaced and kept as <file>.old.
#
# It also makes the mail root's folders, the list's and the sent
# folder that mbsync never syncs, and an empty password file for Pat to
# fill in. It never changes a password file that exists.
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

# mbsync dumped core on beastie on a first sync into folders that did
# not exist, though Create Near should make them.
for box in INBOX Next Later Archive sent; do
	install -d "${root}/${box}/cur" "${root}/${box}/new" "${root}/${box}/tmp"
done

install -d -m 0700 "${pwdir}"
if [ ! -e "${pwfile}" ]; then
	install -m 0600 /dev/null "${pwfile}"
	echo "Write the password of pat@p7x.dev on lab-mail into ${pwfile}"
fi
