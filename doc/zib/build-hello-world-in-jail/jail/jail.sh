#!/bin/sh
set -eu
set -o pipefail

DOAS=${DOAS:-doas}
SRCDIR=${SRCDIR:-$(dirname $(realpath ${0}))/../src}

# make the jail
# copy the files
# execute make
main() {
	make_jail
	copy_source
	start_jail
	run_make "${@}"
	stop_jail
}

make_jail() {
	if [ ! -f tmp/jail/COPYRIGHT ]; then
		mkdir -p tmp
		${DOAS} mkdir -p tmp/jail/usr/share
		${DOAS} cp -Rp /usr/share/keys tmp/jail/usr/share
		${DOAS} pkg -r tmp/jail install -r FreeBSD-base -y \
		    FreeBSD-set-base-jail
	fi
}

copy_source() {
	${DOAS} mkdir -p tmp/jail/wrksrc
	for f in hello.c Makefile; do
		[ -f tmp/jail/wrksrc/${f} ] ||
			${DOAS} cp ${SRCDIR}/${f} tmp/jail/wrksrc
	done
}

start_jail() {
	jls -c -j jello-world || ${DOAS} jail -f jail.conf -c jello-world
}

stop_jail() {
	${DOAS} jail -f jail.conf -r jello-world
}

run_make() {
	${DOAS} jexec -l -d /wrksrc jello-world make "${@}"
}

main "${@}"
