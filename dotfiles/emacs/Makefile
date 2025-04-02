DESTDIR?=	${HOME}/.emacs.d

.PHONY: install
.MAIN: install

SRC_FILES=	init.el \
		packages/consult-2.2/*.el \
		packages/consult-project-extra-982e800/*.el \
		packages/marginalia-2.0/*.el \
		packages/orderless-1.4/*.el \
		packages/term-keys-5677d06/*.el \
		packages/vertico-2.0/*.el \
		packages/vertico-2.0/extensions/*.el \
		packages/xclip-1.11.1/*.el

install: ${SRC_FILES}
.for f in ${SRC_FILES}
	@mkdir -p ${DESTDIR}/${f:H}/
	cp ${f} ${DESTDIR}/${f:H}/
.endfor
