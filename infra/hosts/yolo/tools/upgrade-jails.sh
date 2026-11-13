#!/bin/sh
#
# upgrade-jails.sh [flags]
#
# Run yolo-jail-upgrade, with the flags given, on each jail that
# jails/instances lists and that is running on yolo. Skip stopped
# jails, and jails' own child jails, which jls also lists. Go on past a
# jail that fails, and fail at the end, naming each. Run it as just
# upgrade-jails.
set -eu

host=yolo.p7x.dev
here="$(dirname "$(realpath "$0")")"
instances="${here}/../jails/instances"

running=$(ssh "${host}" jls name)
failed=""
for name in $(awk '!/^#/ && NF { print $1 }' "${instances}"); do
	echo "${running}" | grep -qxF "${name}" || continue
	echo "==> ${name}"
	ssh "${host}" doas yolo-jail-upgrade "$@" "${name}" ||
		failed="${failed} ${name}"
done
if [ -n "${failed}" ]; then
	echo "E: failed to upgrade:${failed}" >&2
	exit 1
fi
