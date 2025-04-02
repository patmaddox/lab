DESTDIR?=	${HOME}/.emacs.d

.PHONY: build clean install
.MAIN: build

SRC_FILES=	init.el
PACKAGES=	consult-2.2 \
		consult-project-extra-982e800 \
		marginalia-2.0 \
		orderless-1.4 \
		term-keys-5677d06 \
		vertico-2.0 \
		vertico-2.0/extensions \
		xclip-1.11.1

build:
	emacs --batch --init-directory=. -l init.el --eval '(byte-recompile-directory "packages" 0)'

clean:
	find packages -name '*.elc' -delete

install:
	@mkdir -p ${DESTDIR}
	cp init.el ${DESTDIR}/

.for p in ${PACKAGES}
	@mkdir -p ${DESTDIR}/packages/${p}
	cp packages/${p}/*.el ${DESTDIR}/packages/${p}/
	cp packages/${p}/*.elc ${DESTDIR}/packages/${p}/
.endfor
