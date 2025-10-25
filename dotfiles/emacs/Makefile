DESTDIR?=	${HOME}/.emacs.d

.PHONY: install

install:
	test ! -e ${DESTDIR} || (echo "E: DESTDIR already exists" 1>&2 && exit 1)
	mkdir -p ${DESTDIR}
	cp init.el ${DESTDIR}/
