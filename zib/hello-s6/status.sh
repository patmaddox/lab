#!/bin/sh
set -eu
set -o pipefail

if [ -n "$(fuser services/.s6-svscan/lock 2>/dev/null)" ]; then
	sup="running"
else
	sup="stopped"
fi
printf "sup: %s\n" "${sup}"

services=$(ls services/*/run | cut -d '/' -f 2)
for s in ${services}; do
	status=$(s6-svstat services/${s})
	printf "  %s: %s\n" "${s}" "${status}"
done
