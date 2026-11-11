#!/bin/sh
set -eu

# Build the package of yolo's jail configs, one in /etc/jail.conf.d
# for each line of instances, made from jail.conf.in.
# Install on yolo, as root, with: pkg add yolo-jails.pkg

name="yolo-jails"
version="0.0.0"

redo-ifchange instances jail.conf.in

stagedir=$(mktemp -d)
trap "rm -rf ${stagedir}" EXIT

mkdir -p "${stagedir}/etc/jail.conf.d"
grep -v -e '^#' -e '^$' instances | while read -r jail template host repo; do
	sed -e "s/%NAME%/${jail}/g" -e "s/%TEMPLATE%/${template}/g" \
	    -e "s/%HOST%/${host}/g" -e "s|%REPO%|${repo}|g" jail.conf.in \
	    > "${stagedir}/etc/jail.conf.d/${jail}.conf"
done

flatsize=$(find "${stagedir}" -type f -exec stat -f%z {} + | awk '{s+=$1} END {print s}')
paths=$(cd "${stagedir}" && find . -type f | sed 's/^\.//' | sort)

manifest="${stagedir}/+MANIFEST"
cat > "${manifest}" <<EOM
name: ${name}
version: ${version}
origin: local/${name}
comment: yolo's jail configs
maintainer: pat@patmaddox.com
prefix: /
www: https://git.sr.ht/~patmaddox/lab/tree/trunk/item/infra/hosts/yolo/jails
flatsize: ${flatsize:-0}
deps: {
  yolo-jail: { origin: local/yolo-jail, version: 0.0.0 }
}
desc: <<EOD
yolo's jail configs, in /etc/jail.conf.d. See
infra/hosts/yolo/README.org.
EOD
files: {
$(echo "${paths}" | awk 'NF { print "  " $1 ": \"-\"" }')
}
EOM

pkg create -M "${manifest}" -r "${stagedir}" -o "$(dirname "$3")"
mv "$(dirname "$3")/${name}-${version}.pkg" "$3"
