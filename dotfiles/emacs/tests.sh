#!/usr/bin/env atf-sh
src_dir=$(atf_get_srcdir)

EMACS="emacs --batch -l ${HOME}/.emacs.d/init.el"

atf_init_test_cases() {
    atf_add_test_case install
    atf_add_test_case load_config
}

helper::install() {
    make -C ${src_dir} install
}

atf_test_case install
install_head() {
    atf_set 'descr' 'Install the config file to $HOME/.emacs.d'
}

install_body() {
    helper::install
    atf_check test -d ${HOME}/.emacs.d
    atf_check test -f ${HOME}/.emacs.d/init.el
}

atf_test_case load_config
load_config_head() {
    atf_set 'descr' 'Load init.el'
}

load_config_body() {
    helper::install
    atf_check ${EMACS} --eval "t"
}
