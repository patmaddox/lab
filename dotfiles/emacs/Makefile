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

build: tree-sitter/libtree-sitter-elixir.so tree-sitter/libtree-sitter-heex.so
	emacs --batch --init-directory=. -l init.el --eval '(byte-recompile-directory "packages" 0)'

clean:
	find packages -name '*.elc' -delete
	rm tree-sitter/*.so

install:
	@mkdir -p ${DESTDIR}/tree-sitter
	cp init.el ${DESTDIR}/
	cp tree-sitter/*.so ${DESTDIR}/tree-sitter/

.for p in ${PACKAGES}
	@mkdir -p ${DESTDIR}/packages/${p}
	cp packages/${p}/*.el ${DESTDIR}/packages/${p}/
	cp packages/${p}/*.elc ${DESTDIR}/packages/${p}/
.endfor

# This has a bit of a goofy build process with PARSER_REPO_URL for now.
# It seems to be fixed in main
tree-sitter/libtree-sitter-elixir.so:
	@mkdir -p tree-sitter
	@rm -rf /tmp/build-tree-sitter-elixir
	mkdir -p /tmp/build-tree-sitter-elixir
	fetch -o - https://github.com/elixir-lang/tree-sitter-elixir/archive/refs/tags/v0.3.4.tar.gz | tar -C /tmp/build-tree-sitter-elixir -x
	gmake -C /tmp/build-tree-sitter-elixir/tree-sitter-elixir-0.3.4 PARSER_REPO_URL=https://github.com/elixir-lang/tree-sitter-elixir.git
	cp /tmp/build-tree-sitter-elixir/tree-sitter-elixir-0.3.4/libtree-sitter-elixir.so ${.TARGET}

tree-sitter/libtree-sitter-heex.so:
	@mkdir -p tree-sitter
	@rm -rf /tmp/build-tree-sitter-heex
	mkdir -p /tmp/build-tree-sitter-heex
	fetch -o - https://github.com/phoenixframework/tree-sitter-heex/archive/refs/tags/v0.8.0.tar.gz | tar -C /tmp/build-tree-sitter-heex -x
	gmake -C /tmp/build-tree-sitter-heex/tree-sitter-heex-0.8.0
	cp /tmp/build-tree-sitter-heex/tree-sitter-heex-0.8.0/libtree-sitter-heex.so ${.TARGET}
