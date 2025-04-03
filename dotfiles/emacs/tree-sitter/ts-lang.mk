TS_LANG=	${MAKEFILE:S/.mk//}
TS_LANG_DIR?=	${TS_LANG}

_build/libtree-sitter-${TS_LANG}.so:
	@mkdir -p _build
	fetch -o - https://github.com/${GH_REPO}/archive/refs/tags/v${TS_VERS}.tar.gz | tar -C _build -x
	gmake -C _build/tree-sitter-${TS_LANG_DIR}-${TS_VERS} ${TS_FLAGS}
	cp _build/tree-sitter-${TS_LANG_DIR}-${TS_VERS}/libtree-sitter-${TS_LANG}.so ${.TARGET}
