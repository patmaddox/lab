#!/bin/sh
set -u

test() {
	local name sleep_s wait_s w1 w2
	name="${1}"; shift
	sleep_s=${1}; shift
	wait_s=${1}; shift

	echo "${name}"
	./worker.sh ${sleep_s} ${wait_s} &
	w1=$!
	echo "w1: ${w1}"
	./worker.sh ${sleep_s} ${wait_s} &
	w2=$!
	echo "w2: ${w2}"
	pwait $w1 $w2
}

test "fail immediately" 1 0
test "fail after 1 second" 2 1
test "succeed after 1 second" 1 2
