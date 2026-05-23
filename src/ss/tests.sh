#!/usr/bin/env atf-sh

export PATH=$(atf_get_srcdir):$PATH

atf_init_test_cases() {
	atf_add_test_case hello_world
	atf_add_test_case hello_world_rebuild_clean
	atf_add_test_case hello_world_vars
	atf_add_test_case named_build_function
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

atf_test_case hello_world_rebuild_clean
hello_world_rebuild_clean_head() {
	atf_set "descr" "Rebuild a target with no changed deps"
}
hello_world_rebuild_clean_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:0 -e inline:"hello\n" ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	echo "rebuilding..."
	atf_check -s eq:0 ss
}

atf_test_case hello_world_vars
hello_world_vars_head() {
	atf_set "descr" "Build a target using framework vars"
}
hello_world_vars_body() {
	cp -r "$(atf_get_srcdir)/examples/2_hello_world_vars" work
	cd work
	atf_check -s eq:0 -e inline:"hello\n" ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case named_build_function
named_build_function_head() {
	atf_set "descr" "Target with a named build function"
}
named_build_function_body() {
	cp -r "$(atf_get_srcdir)/examples/3_named_build_function" work
	cd work
	atf_check -s eq:0 -e inline:"hello.out\n" ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello.out
}
