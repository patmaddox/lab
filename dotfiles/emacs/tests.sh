#!/usr/bin/env atf-sh
src_dir=$(atf_get_srcdir)

EMACS="emacs --batch -l ${src_dir}/testconfig.el -l ${HOME}/.emacs.d/init.el"

atf_init_test_cases() {
    atf_add_test_case install
    atf_add_test_case languages
}

helper::install() {
    atf_check -o ignore -e ignore make -C ${src_dir} -s
    atf_check make -C ${src_dir} -s install
}

## install
atf_test_case install
install_head() {
    atf_set 'descr' 'Install config file and compiled packages to $HOME/.emacs.d, load init.el'
}

install_body() {
    helper::install

    atf_check test -d ${HOME}/.emacs.d
    atf_check test -f ${HOME}/.emacs.d/init.el
    atf_check test ! -f ${HOME}/.emacs.d/init.elc
    atf_check -o not-empty find ${HOME}/.emacs.d/packages -name '*.elc'
    atf_check ${EMACS} --eval 't'
}

## languages
atf_test_case languages
languages_head() {
    atf_set 'descr' 'Languages configuration'
}

languages_body() {
    helper::install

    atf_check ${EMACS} -f elixir-ts-mode
    atf_check ${EMACS} -f gfm-mode
    atf_check ${EMACS} -f go-ts-mode
    atf_check ${EMACS} -f go-mod-ts-mode
    atf_check ${EMACS} -f heex-ts-mode
    atf_check ${EMACS} -f lua-ts-mode
    atf_check ${EMACS} -f markdown-mode
    atf_check ${EMACS} -f rust-ts-mode
}
