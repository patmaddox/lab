#!/bin/sh
set -eu
set -o pipefail

usage() {
	echo "Usage: ./worker.sh <sleep_s> <wait_s>"
}

sleep_s=${1:?$(usage)}; shift
wait_s=${1:?$(usage)}; shift

echo "${$} starting"
exec 9> /tmp/lockf-worker.lock
lockf -k -s -t ${wait_s} 9 || (echo "E: ${$} unable to acquire lock" && exit 1)
sleep ${sleep_s}
echo "${$} done"
