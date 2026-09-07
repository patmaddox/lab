#!/bin/sh
set -eu
set -o pipefail

readonly name=${1}; shift

mkdir -p ${name}
if [ ! -e ${name}/clean.do ]; then
	ln -s ../../libexec/_clean.do ${name}/clean.do
fi
if [ ! -e ${name}/jail.log.do ]; then
	ln -s ../../libexec/_jail.log.do ${name}/jail.log.do
fi
if [ ! -e ${name}/Justfile ]; then
	ln -s ../../share/_Justfile ${name}/Justfile
fi
if [ ! -e ${name}/hal.instance.conf ]; then
	cp ../tools/init-instance/hal.instance.conf ${name}/
fi
if [ ! -e ${name}/jail.conf ]; then
	sed -e "s/%NAME%/${name}/g" ../tools/init-instance/jail.conf > ${name}/jail.conf
fi
