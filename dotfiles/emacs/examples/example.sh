#!/bin/sh
# Example POSIX shell script for FreeBSD style

usage()
{
	echo "Usage: $0 [-v] <command>"
	exit 1
}

verbose=0

while getopts "v" opt; do
	case "$opt" in
	v)
		verbose=1
		;;
	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
	usage
fi

command="$1"

if [ "$verbose" -eq 1 ]; then
	echo "Running: $command"
fi

eval "$command"
