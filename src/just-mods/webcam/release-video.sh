#!/bin/sh
set -eu

main() {
    cmd="${1:-}"

    case "${cmd}" in
	ls | kill)
            cmd::${cmd}
            ;;
	*)
	    usage
	    exit 1
	    ;;
    esac

}

cmd::ls() {
    fstat /dev/video* \
	| grep -v PID \
	| cut -w -f 3 \
	| sort -u \
	| xargs ps
}

cmd::kill() {
    cmd::ls \
	| grep tab$ \
	| cut -w -f 1 \
	| sort \
	| xargs kill
}

usage() {
    cat << EOF
Usage:
  release-video.sh ls
  release-video.sh kill
EOF
}

main "${@}"
