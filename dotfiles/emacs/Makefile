DESTDIR?=	${HOME}/.emacs.d

.PHONY: install

install:
	test ! -e ${DESTDIR} || (echo "E: DESTDIR already exists" 1>&2 && exit 1)
	mkdir -p ${DESTDIR}
	cp init.el ${DESTDIR}/
	for d in $$(find dist -type d); do mkdir ${DESTDIR}/$${d}; done
	for f in $$(jj file list dist); do cp $${f} ${DESTDIR}/$${f}; done
