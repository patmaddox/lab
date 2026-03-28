#!/bin/sh
set -eu

CLAUDE="$(jj root)/dotfiles/emacs/lisp/claude-code/claude-jail.sh"
LOCK="$(jj root)/.jj/claude.lock"
MAX=1

while getopts n: opt; do
	case "${opt}" in
	n) MAX="${OPTARG}" ;;
	*)
		echo "Usage: iterate.sh [-n max] <plan-file>" >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

if [ $# -ne 1 ]; then
	echo "Usage: iterate.sh [-n max] <plan-file>" >&2
	exit 1
fi

PLAN="${1}"

if [ ! -f "${PLAN}" ]; then
	echo "Error: plan file not found: ${PLAN}" >&2
	exit 1
fi

i=1
while [ "${i}" -le "${MAX}" ]; do
	echo "[${i}/${MAX}]"

	output=$(${CLAUDE} -p "@prompts/iterate.md iterate on @${PLAN}")
	signal=$(echo "${output}" | awk -F: '$1=="%iterate%"{print $2; exit}')
	action=$(echo "${output}" | awk -F: '$1=="%iterate%"{print $3; exit}')

	case "${signal}" in
	ok)
		echo "Done: ${PLAN}"
		exit 0
		;;
	halt)
		echo "${PLAN}"
		exit 0
		;;
	continue)
		;;
	*)
		echo "Error: unknown signal: ${signal}" >&2
		exit 1
		;;
	esac

	echo "Action: ${action} ${PLAN}"

	case "${action}" in
	plan)
		${CLAUDE} -p "@prompts/plan.md develop @${PLAN}"
		;;
	implement)
		${CLAUDE} -p "@prompts/implement.md implement @${PLAN}"
		;;
	*)
		echo "Error: unknown action: ${action}" >&2
		exit 1
		;;
	esac

	# Commit if files were modified
	has_changes=$(lockf -k "${LOCK}" jj status 2>&1)
	if echo "${has_changes}" | grep -q '^[AMDR]'; then
		lockf -k "${LOCK}" jj commit -m "[WIP] iterate: ${action} ${PLAN}"
	fi

	i=$((i + 1))
done

echo "Reached max iterations (${MAX}): ${PLAN}"
