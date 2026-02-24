#!/usr/bin/env atf-sh
src_dir=$(atf_get_srcdir)

atf_init_test_cases() {
	atf_add_test_case basic
	atf_add_test_case stream
}

atf_test_case basic
basic_head() {
	atf_set "descr" "Basic shanty"
}
basic_body() {
	atf_check ${src_dir}/shanty ${src_dir}/fixtures/basic.shanty
	atf_check -o inline:"foo local\nfoo remote\nbar remote\n" cat foo.remote
}

atf_test_case stream
stream_head() {
	atf_set "descr" "Stream shanty"
}
stream_body() {
	atf_check ${src_dir}/shanty ${src_dir}/fixtures/stream.shanty
	atf_check -o inline:"foo local\nfoo remote\nbar remote\n" cat foo.remote
}
