#!/usr/bin/env atf-sh
src_dir=$(atf_get_srcdir)

atf_init_test_cases() {
    atf_add_test_case simple_test
}

atf_test_case simple_test
simple_test_head() {
    atf_set "descr" "Just a simple test"
}

simple_test_body() {
    atf_check true
}
