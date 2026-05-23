#!/usr/bin/env atf-sh

export PATH=$(atf_get_srcdir):$PATH

atf_init_test_cases() {
	atf_add_test_case hello_world
	atf_add_test_case hello_world_rebuild_clean
	atf_add_test_case hello_world_rebuild_dirty
	atf_add_test_case hello_world_vars
	atf_add_test_case named_build_function
	atf_add_test_case multiple_deps
	atf_add_test_case multiple_targets
	atf_add_test_case multiple_targets_reverse
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

atf_test_case hello_world_rebuild_dirty
hello_world_rebuild_dirty_head() {
	atf_set "descr" "Rebuild a target with a changed dep"
}
hello_world_rebuild_dirty_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:0 -e inline:"hello\n" ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	sed -i -e 's/world/ss/' hello.c

	echo "rebuilding..."
	atf_check -s eq:0 -e inline:"hello\n" ss
	atf_check -s eq:0 -o inline:"hello ss\n" ./hello
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

atf_test_case multiple_deps
multiple_deps_head() {
	atf_set "descr" "Target with multiple dependencies"
}
multiple_deps_body() {
	cp -r "$(atf_get_srcdir)/examples/4_multiple_deps" work
	cd work
	atf_check -s eq:0 -e inline:"hello\n" ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case multiple_targets
multiple_targets_head() {
	atf_set "descr" "Multiple targets with dependency ordering"
}
multiple_targets_body() {
	cp -r "$(atf_get_srcdir)/examples/5_multiple_targets" work
	cd work
	atf_check -s eq:0 -e inline:"libhello.o\nhello\n" ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case multiple_targets_reverse
multiple_targets_reverse_head() {
	atf_set "descr" "Multiple targets with reverse declaration order"
}
multiple_targets_reverse_body() {
	cp -r "$(atf_get_srcdir)/examples/6_multiple_targets_reverse" work
	cd work
	atf_check -s eq:0 -e inline:"libhello.o\nhello\n" ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}
