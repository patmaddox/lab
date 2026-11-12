#!/bin/sh
set -eu

# Build the package of yolo's jail configs, one in /etc/jail.conf.d
# for each line of instances, made from jail.conf.in, and instances
# itself, which yolo-jail-init reads.
# yolo's BE carries it, and just install-pkg installs a newer one
# from the repository on yolo.

name="yolo-jails"
# Its version is the time it was built. redo rebuilds it only when what
# it holds changes, so the version moves only then, and pkg on yolo
# upgrades to it from the repository.
version=$(date -u +%Y.%m.%d.%H%M%S)

redo-ifchange instances jail.conf.in

stagedir=$(mktemp -d)
trap "rm -rf ${stagedir}" EXIT

mkdir -p "${stagedir}/etc/jail.conf.d"
# Print jail.conf.in, with each line that names %REPO% repeated once
# for each of the jail's repos.
repeat_repo_lines() {
	while IFS= read -r line; do
		case ${line} in
		*%REPO%*)
			for repo in ${repos}; do
				printf '%s\n' "${line}" | sed "s|%REPO%|${repo}|g"
			done
			;;
		*)
			printf '%s\n' "${line}"
			;;
		esac
	done < jail.conf.in
}

# repos is the rest of the line: one or more repos.
grep -v -e '^#' -e '^$' instances | while read -r jail template host repos; do
	if [ -z "${repos}" ]; then
		echo "E: jail ${jail} has no repo in instances" >&2
		exit 1
	fi
	repeat_repo_lines |
	    sed -e "s/%NAME%/${jail}/g" -e "s/%TEMPLATE%/${template}/g" \
	    -e "s/%HOST%/${host}/g" > "${stagedir}/etc/jail.conf.d/${jail}.conf"
done

# yolo-jail-init finds each jail's template and repo here.
mkdir -p "${stagedir}/usr/local/share/yolo-jails"
install -m 0444 instances "${stagedir}/usr/local/share/yolo-jails/instances"

flatsize=$(find "${stagedir}" -type f -exec stat -f%z {} + | awk '{s+=$1} END {print s}')
paths=$(cd "${stagedir}" && find . -type f | sed 's/^\.//' | sort)

manifest="${stagedir}/+MANIFEST"
cat > "${manifest}" <<EOM
name: ${name}
version: "${version}"
origin: local/${name}
comment: yolo's jail configs
maintainer: pat@patmaddox.com
prefix: /
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/infra/hosts/yolo/jails
flatsize: ${flatsize:-0}
# pkg resolves a dependency by its name, so its version is only
# recorded.
deps: {
  yolo-jail: { origin: local/yolo-jail, version: "0" }
}
desc: <<EOD
yolo's jail configs, in /etc/jail.conf.d, and the list of its jails.
See infra/hosts/yolo/README.org.
EOD
files: {
$(echo "${paths}" | awk 'NF { print "  " $1 ": \"-\"" }')
}
EOM

pkg create -M "${manifest}" -r "${stagedir}" -o "$(dirname "$3")"
mv "$(dirname "$3")/${name}-${version}.pkg" "$3"
