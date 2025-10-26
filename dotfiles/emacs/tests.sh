#!/usr/bin/env atf-sh
src_dir=$(atf_get_srcdir)

atf_init_test_cases() {
    atf_add_test_case install_and_load
}

helper::install() {
    atf_check make -C ${src_dir} -s
}

## install_and_load
atf_test_case install_and_load
install_and_load_head() {
    atf_set 'descr' 'Install config file and compiled packages to $HOME/.emacs.d, load init.el, check modes and stuff'
}

install_and_load_body() {
    helper::install

    atf_check test -d ${HOME}/.emacs.d

    # compile everything except for init.el
    atf_check test -f ${HOME}/.emacs.d/init.el
    atf_check test ! -f ${HOME}/.emacs.d/init.elc

    # run the elisp check that files load with correct modes etc
    # emacs can be noisy, so just focus on error code
    atf_check -o ignore -e ignore emacs --batch \
	      -l ${src_dir}/test-init.el \
	      -l ${HOME}/.emacs.d/init.el \
	      -l ${src_dir}/tests.el
}
