#!/bin/sh
# Set up the claude user's lab workspaces: lab/default.jj for trunk
# and lab/mail.jj for the mail list.  Run once after the jail is
# built; safe to run again.
set -eu

readonly upstream=/data/lab.git
readonly submissions=/data/lab-submissions.git
readonly repo=${HOME}/lab/default.jj
readonly mailws=${HOME}/lab/mail.jj

if [ ! -d ${repo} ]; then
	mkdir -p $(dirname ${repo})
	jj git clone --remote upstream ${upstream} ${repo}
	jj -R ${repo} git remote add submissions ${submissions}
fi

cd ${repo}
jj config set --repo 'revset-aliases."trunk()"' trunk@upstream
jj config set --repo git.push submissions
jj git fetch --all-remotes
jj bookmark track trunk@upstream mail@upstream

if [ ! -d ${mailws} ]; then
	jj workspace add --name mail -r mail ${mailws}
fi

# notmuch hooks and config come from the same package as on any
# developer machine; only the identity is claude's, taken from the
# .gitconfig installed with the jail.  Set it before the first notmuch
# new so the first tags are derived for claude.
(cd ${repo}/dotfiles/notmuch && just install)
notmuch config set user.name "$(git config user.name)"
notmuch config set user.primary_email "$(git config user.email)"

notmuch new
