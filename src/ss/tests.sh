#!/usr/bin/env atf-sh

export PATH=$(atf_get_srcdir):$PATH

atf_init_test_cases() {
	atf_add_test_case hello_world
}

atf_test_case hello_world
hello_world_head() {
	atf_set "descr" "Build a target with explicit commands"
}
hello_world_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:0 -e inline:"hello\n" ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}
