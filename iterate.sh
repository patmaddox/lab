#!/bin/sh
set -eu

if [ $# -ne 1 ]; then
	echo "Usage: iterate.sh <plan-file>" >&2
	exit 1
fi

PLAN="${1}"

if [ ! -f "${PLAN}" ]; then
	echo "Error: plan file not found: ${PLAN}" >&2
	exit 1
fi

CLAUDE="$(jj root)/dotfiles/emacs/lisp/claude-code/claude-jail.sh"

output=$(${CLAUDE} -p "@prompts/iterate.md iterate on @${PLAN}")
signal=$(echo "${output}" | awk -F: '$1=="%iterate%"{print $2; exit}')
action=$(echo "${output}" | awk -F: '$1=="%iterate%"{print $3; exit}')

case "${signal}" in
ok)
	echo "Done: ${PLAN}"
	;;
halt)
	echo "${PLAN}"
	;;
continue)
	echo "Action: ${action}"
	;;
*)
	echo "Error: unknown signal: ${signal}" >&2
	exit 1
	;;
esac
