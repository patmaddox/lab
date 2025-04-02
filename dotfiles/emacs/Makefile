DESTDIR?=	${HOME}/.emacs.d

.PHONY: install
.MAIN: install

SRC_FILES=	init.el \
		packages/consult-2.2/*.el

install: ${SRC_FILES}
.for f in ${SRC_FILES}
	@mkdir -p ${DESTDIR}/${f:H}/
	cp ${f} ${DESTDIR}/${f:H}/
.endfor
