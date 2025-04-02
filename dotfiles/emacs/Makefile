DESTDIR?=	${HOME}/.emacs.d

.PHONY: install

install: ${DESTDIR}/init.el

${DESTDIR}/init.el: init.el
	@mkdir -p ${.TARGET:H}
	cp ${.ALLSRC} ${.TARGET}
