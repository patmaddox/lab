#!/bin/sh
set -eu

CLAUDE="$(jj root)/dotfiles/emacs/lisp/claude-code/claude-jail.sh"
LOCK="$(jj root)/.jj/claude.lock"
MAX=1

while getopts n: opt; do
	case "${opt}" in
	n) MAX="${OPTARG}" ;;
	*)
		echo "Usage: iterate.sh [-n max] <plan-file>..." >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
	echo "Usage: iterate.sh [-n max] <plan-file>..." >&2
	exit 1
fi

for f in "$@"; do
	if [ ! -f "${f}" ]; then
		echo "Error: plan file not found: ${f}" >&2
		exit 1
	fi
done

iterate_file() {
	local i plan
	plan="${1}"
	i=1
	while [ "${i}" -le "${MAX}" ]; do
		echo "[${i}/${MAX}] ${plan}"

		output=$(${CLAUDE} -p "@prompts/iterate.md iterate on @${plan}")
		signal=$(echo "${output}" | awk -F: '$1=="%iterate%"{print $2; exit}')
		action=$(echo "${output}" | awk -F: '$1=="%iterate%"{print $3; exit}')

		case "${signal}" in
		ok)
			echo "Done: ${plan}"
			return 0
			;;
		halt)
			echo "${plan}"
			return 0
			;;
		continue)
			;;
		*)
			echo "Error: unknown signal: ${signal}" >&2
			return 1
			;;
		esac

		echo "Action: ${action} ${plan}"

		case "${action}" in
		plan)
			${CLAUDE} -p "@prompts/plan.md develop @${plan}"
			;;
		implement)
			${CLAUDE} -p "@prompts/implement.md implement @${plan}"
			;;
		*)
			echo "Error: unknown action: ${action}" >&2
			return 1
			;;
		esac

		# Commit if files were modified
		has_changes=$(lockf -k "${LOCK}" jj status 2>&1)
		if echo "${has_changes}" | grep -q '^[AMDR]'; then
			lockf -k "${LOCK}" jj commit -m "[CLAUDE] iterate ${action} ${plan}"
		fi

		i=$((i + 1))
	done

	echo "Reached max iterations (${MAX}): ${plan}"
}

for f in "$@"; do
	iterate_file "${f}"
done
