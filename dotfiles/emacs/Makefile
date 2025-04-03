DESTDIR?=	${HOME}/.emacs.d

.PHONY: build clean install
.MAIN: build

PACKAGES=	consult-2.2 \
		consult-project-extra-982e800 \
		marginalia-2.0 \
		markdown-mode-2.7 \
		orderless-1.4 \
		term-keys-5677d06 \
		vertico-2.0 \
		vertico-2.0/extensions \
		xclip-1.11.1

TS_LANGS=	elixir \
		go \
		gomod \
		heex \
		lua \
		rust

LANG_TO_OBJ=	C/.*/tree-sitter\/_build\/libtree-sitter-&.so/

TS_OBJS=	${TS_LANGS:${LANG_TO_OBJ}}

build: ${TS_OBJS}
	emacs --batch --init-directory=. -l init.el --eval '(byte-recompile-directory "packages" 0)'

clean:
	find packages -name '*.elc' -delete
	rm -rf tree-sitter/_build

install:
	@mkdir -p ${DESTDIR}/tree-sitter
	cp init.el ${DESTDIR}/
	cp tree-sitter/_build/*.so ${DESTDIR}/tree-sitter/

.for p in ${PACKAGES}
	@mkdir -p ${DESTDIR}/packages/${p}
	cp packages/${p}/*.el ${DESTDIR}/packages/${p}/
	cp packages/${p}/*.elc ${DESTDIR}/packages/${p}/
.endfor

# recursively build the languages
.for l in ${TS_LANGS}
${l:${LANG_TO_OBJ}}:
	${MAKE} -C tree-sitter -f ${l}.mk
.endfor
