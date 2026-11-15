#!/bin/sh
#
# init-jails.sh
#
# Run yolo-jail-init on each jail that jails/instances lists, one
# after another. yolo-jail-init refuses a running jail, so stop those
# first. Go on past a jail that fails, and fail at the end, naming
# each. Run it as just init-jails.
set -eu

host=yolo.p7x.dev
here="$(dirname "$(realpath "$0")")"
instances="${here}/../jails/instances"

failed=""
for name in $(awk '!/^#/ && NF { print $1 }' "${instances}"); do
	echo "==> ${name}"
	ssh "${host}" doas yolo-jail-init "${name}" ||
		failed="${failed} ${name}"
done
if [ -n "${failed}" ]; then
	echo "E: failed to set up:${failed}" >&2
	exit 1
fi
