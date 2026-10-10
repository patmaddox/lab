#!/bin/sh
# Set up the claude user's lab workspaces: lab/default.jj for trunk
# and lab/mail.jj for the mail list.  Run once after the jail is
# built; safe to run again.
set -eu

readonly upstream=/data/lab.git
readonly submissions=/data/lab-submissions.git
readonly repo=${HOME}/lab/default.jj
readonly mailws=${HOME}/lab/mail.jj

# The shared repos are owned by the host user, so git refuses them
# as dubious ownership until they are marked safe.
_safe_directory() {
	if ! git config --global --get-all safe.directory | grep -qxF "${1}"; then
		git config --global --add safe.directory "${1}"
	fi
}

_safe_directory ${upstream}
_safe_directory ${submissions}

jj config set --user user.name "$(whoami)"
jj config set --user user.email "$(whoami)@p7x.dev"

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

notmuch new
