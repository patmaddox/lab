#!/bin/sh
set -eu

main() {
    IFS=$'\n'
    curdir=$(pwd)
    local repodir
    repodir=${1}; shift

    cd ${repodir}
    local change port
    for c in $(changes); do
	change=$(echo ${c} | cut -w -f 1)
	port=$(echo ${c} | cut -w -f 2)

	echo "=== BEG TEST ${port} @ ${change}"
	jj edit ${change}
	doas poudriere testport -j 142 -p dev ${port}
	echo "=== END TEST ${port} @ ${change}"
    done
}

changes() {
    jj -R ${repodir} log -r 'pending()' --no-graph -T 'change_id ++ " " ++ description.first_line() ++ "\n"' --color never | sed -e 's/:.*//'
}

main "${@}"
