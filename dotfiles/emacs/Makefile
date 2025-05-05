DESTDIR?=	${HOME}/.emacs.d

.PHONY: build clean install
.MAIN: build

PACKAGES=	consult-2.2 \
		consult-project-extra-982e800 \
		denote-7bb8b7c \
		llama-0.6.2 \
		magit-4.3.3/lisp \
		marginalia-2.0 \
		markdown-mode-2.7 \
		orderless-1.4 \
		term-keys-5677d06 \
		vertico-2.0 \
		vertico-2.0/extensions \
		with-editor-3.4.3/lisp \
		xclip-1.11.1 \
		zig-ts-mode-3898b70

TS_LANGS=	elixir \
		go \
		gomod \
		heex \
		lua \
		rust \
		zig

LANG_TO_OBJ=	C/.*/tree-sitter\/_build\/libtree-sitter-&.so/

TS_OBJS=	${TS_LANGS:${LANG_TO_OBJ}}

build: ${TS_OBJS}
	emacs --batch --init-directory=. -l init.el --eval '(byte-recompile-directory "packages" 0)'

clean:
	find packages -name '*.elc' -delete
	rm -rf tree-sitter/_build

install:
	test ! -e ${DESTDIR} || (echo "E: DESTDIR already exists" 1>&2 && exit 1)
	@mkdir -p ${DESTDIR}/tree-sitter
	cp init.el ${DESTDIR}/
	cp tree-sitter/_build/*.so ${DESTDIR}/tree-sitter/
	for d in $$(find dist -type d); do mkdir ${DESTDIR}/$${d}; done
	for f in $$(jj file list dist); do cp $${f} ${DESTDIR}/$${f}; done

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
