#!/bin/sh
set -eu

# Build the package of yolo's jail configs, one in /etc/jail.conf.d
# for each line of instances, made from jail.conf.in, and instances
# itself and peers, which yolo-jail-init reads.
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

share="${stagedir}/usr/local/share/yolo-jails"
mkdir -p "${stagedir}/etc/jail.conf.d" "${share}"

# A jail's peers are the other jails that share a repo with it. Write
# one line for each jail: the jail, then its peers, if any.
awk '!/^#/ && NF {
	n++
	jail[n] = $1
	nrepos[n] = NF - 3
	for (i = 4; i <= NF; i++) {
		repo[n, i - 3] = $i
		has[$1, $i] = 1
	}
}
END {
	for (a = 1; a <= n; a++) {
		line = jail[a]
		for (b = 1; b <= n; b++) {
			if (b == a)
				continue
			for (k = 1; k <= nrepos[a]; k++) {
				if ((jail[b], repo[a, k]) in has) {
					line = line " " jail[b]
					break
				}
			}
		}
		print line
	}
}' instances > "${share}/peers"
chmod 0444 "${share}/peers"

# Print jail.conf.in, with each line that names %REPO% repeated once
# for each of the jail's repos, and each that names %PEER% once for
# each of its peers.
repeat_lines() {
	while IFS= read -r line; do
		case ${line} in
		*%REPO%*)
			for repo in ${repos}; do
				printf '%s\n' "${line}" | sed "s|%REPO%|${repo}|g"
			done
			;;
		*%PEER%*)
			for peer in ${peers}; do
				printf '%s\n' "${line}" | sed "s|%PEER%|${peer}|g"
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
	peers=$(awk -v jail=${jail} '$1 == jail { $1 = ""; print }' "${share}/peers")
	repeat_lines |
	    sed -e "s/%NAME%/${jail}/g" -e "s/%TEMPLATE%/${template}/g" \
	    -e "s/%HOST%/${host}/g" > "${stagedir}/etc/jail.conf.d/${jail}.conf"
done

# yolo-jail-init finds each jail's template, repos, and peers here.
install -m 0444 instances "${share}"

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
