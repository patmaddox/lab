#!/usr/bin/env atf-sh
src_dir=$(atf_get_srcdir)

atf_init_test_cases() {
	atf_add_test_case basic
	atf_add_test_case stream
	atf_add_test_case pull
	atf_add_test_case no_mode
	atf_add_test_case two_modes
	atf_add_test_case bad_mode
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

atf_test_case pull
pull_head() {
	atf_set "descr" "Pull shanty"
}
pull_body() {
	atf_check ${src_dir}/shanty ${src_dir}/fixtures/pull.shanty
	atf_check -o inline:"foo remote\nfoo local\nbar remote\nbar local\n" cat foo.local
}

atf_test_case no_mode
no_mode_head() {
	atf_set "descr" "Require a mode"
}
no_mode_body() {
	cat<<EOF > no_mode.shanty
shanty_init() { }
EOF
	atf_check -s not-exit:0 -e inline:"E: Must call shanty_mode with push or pull\n" ${src_dir}/shanty no_mode.shanty
}

atf_test_case two_modes
two_modes_head() {
	atf_set "descr" "Can only set mode once"
}
two_modes_body() {
	cat<<EOF > two_modes.shanty
shanty_init() {
shanty_mode push
shanty_mode pull
}
EOF
	atf_check -s not-exit:0 -e inline:"E: Must call shanty_mode only once\n" ${src_dir}/shanty two_modes.shanty
}

atf_test_case bad_mode
bad_mode_head() {
	atf_set "descr" "Validate mode"
}
bad_mode_body() {
	cat<<EOF > bad_mode.shanty
shanty_init() {
shanty_mode foo
}
EOF
	atf_check -s not-exit:0 -e inline:"E: Unknown shanty_mode: foo\n" ${src_dir}/shanty bad_mode.shanty
}
