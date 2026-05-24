#!/usr/bin/env atf-sh

export PATH=$(atf_get_srcdir):$PATH

atf_init_test_cases() {
	# basics
	atf_add_test_case hello_world
	atf_add_test_case silent_build
	atf_add_test_case named_build_function

	# dependencies
	atf_add_test_case multiple_deps
	atf_add_test_case multiple_targets
	atf_add_test_case implicit_deps
	atf_add_test_case named_inputs
	atf_add_test_case shared_dep

	# rebuild
	atf_add_test_case rebuild_clean
	atf_add_test_case rebuild_dirty
	atf_add_test_case implicit_deps_rebuild

	# stamps
	atf_add_test_case stamp_stable
	atf_add_test_case stamp_changing

	# target selection
	atf_add_test_case named_file
	atf_add_test_case select_targets
	atf_add_test_case mixed_sources

	# produces
	atf_add_test_case produces
	atf_add_test_case produces_multiple
	atf_add_test_case produces_rebuild_deleted
	atf_add_test_case produces_rebuild_modified
	atf_add_test_case produces_select
	atf_add_test_case produces_ls
	atf_add_test_case produces_clean
	atf_add_test_case produces_checksum_consumer

	# out-of-tree
	atf_add_test_case outdir_not_enabled
	atf_add_test_case outdir_enabled
	atf_add_test_case outdir_multiple
	atf_add_test_case outdir_mixed

	# listing and clean
	atf_add_test_case ls_targets
	atf_add_test_case clean
	atf_add_test_case clean_selective

	# errors
	atf_add_test_case unknown_command
	atf_add_test_case bad_flag
	atf_add_test_case failed_dep
	atf_add_test_case failed_downstream
	atf_add_test_case missing_dep
	atf_add_test_case cycle
	atf_add_test_case missing_output
	atf_add_test_case produces_missing
	atf_add_test_case produces_conflict_dup
	atf_add_test_case produces_conflict_explicit
	atf_add_test_case produces_conflict_implicit
	atf_add_test_case produces_conflict_multiple
	atf_add_test_case produces_conflict_target_name
	atf_add_test_case clean_unknown_target

	# edge cases
	atf_add_test_case colon_target
	atf_add_test_case slash_dep
	atf_add_test_case target_vs_outfile
	atf_add_test_case deps_dir_per_cwd
}

#
# basics
#

atf_test_case hello_world
hello_world_head() {
	atf_set "descr" "Build a target using framework vars"
}
hello_world_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case silent_build
silent_build_head() {
	atf_set "descr" "Successful build produces no output without -d"
}
silent_build_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:0 -o empty -e empty ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case named_build_function
named_build_function_head() {
	atf_set "descr" "Target with a named build function"
}
named_build_function_body() {
	cp -r "$(atf_get_srcdir)/examples/2_named_build_function" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello.out
ss: built hello.out
ss: checksum hello.c
ss: checksum hello.out
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello.out
}

#
# dependencies
#

atf_test_case multiple_deps
multiple_deps_head() {
	atf_set "descr" "Target with multiple dependencies"
}
multiple_deps_body() {
	cp -r "$(atf_get_srcdir)/examples/3_multiple_deps" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
ss: checksum libhello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case multiple_targets
multiple_targets_head() {
	atf_set "descr" "Multiple targets with dependency ordering"
}
multiple_targets_body() {
	cp -r "$(atf_get_srcdir)/examples/4_multiple_targets" work
	cd work
	cat > expected.err <<'EOF'
ss: build libhello.o
ss: built libhello.o
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
ss: checksum libhello.c
ss: checksum libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	# declaration order does not matter
	atf_check -s eq:0 ss clean
	mv all.ss all.ss.bak
	mv reverse.ss all.ss
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case implicit_deps
implicit_deps_head() {
	atf_set "descr" "Implicit deps excluded from deps var"
}
implicit_deps_body() {
	cp -r "$(atf_get_srcdir)/examples/5_implicit_deps" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
ss: checksum hello.h
ss: checksum note.txt
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case named_inputs
named_inputs_head() {
	atf_set "descr" "Named inputs set shell variables for build function"
}
named_inputs_body() {
	cp -r "$(atf_get_srcdir)/examples/6_named_inputs" work
	cd work
	cat > expected.err <<'EOF'
ss: build libhello.o
ss: built libhello.o
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
ss: checksum libhello.c
ss: checksum libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case shared_dep
shared_dep_head() {
	atf_set "descr" "Changing a shared dep rebuilds all dependent targets"
}
shared_dep_body() {
	cp -r "$(atf_get_srcdir)/examples/7_shared_dep" work
	cd work
	atf_check -s eq:0 ss
	atf_check -s eq:0 -o inline:"v1\n" cat foo
	atf_check -s eq:0 -o inline:"v1\n" cat bar

	echo "v2" > shared.txt
	atf_check -s eq:0 ss
	atf_check -s eq:0 -o inline:"v2\n" cat foo
	atf_check -s eq:0 -o inline:"v2\n" cat bar
}

#
# rebuild
#

atf_test_case rebuild_clean
rebuild_clean_head() {
	atf_set "descr" "Rebuild a target with no changed deps"
}
rebuild_clean_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:0 -e ignore ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	cat > expected.err <<'EOF'
ss: checksum hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
}

atf_test_case rebuild_dirty
rebuild_dirty_head() {
	atf_set "descr" "Rebuild a target with a changed dep"
}
rebuild_dirty_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:0 -e ignore ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	sed -i '' 's/world/ss/' hello.c

	cat > expected.err <<'EOF'
ss: checksum hello
ss: checksum hello.c
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello ss\n" ./hello
}

atf_test_case implicit_deps_rebuild
implicit_deps_rebuild_head() {
	atf_set "descr" "Changing an implicit dep triggers rebuild"
}
implicit_deps_rebuild_body() {
	cp -r "$(atf_get_srcdir)/examples/5_implicit_deps" work
	cd work
	atf_check -s eq:0 -e ignore ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	sed -i '' 's/hello world/hello ss/' hello.h

	cat > expected.err <<'EOF'
ss: checksum hello
ss: checksum hello.c
ss: checksum hello.h
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
ss: checksum hello.h
ss: checksum note.txt
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello ss\n" ./hello
}

#
# stamps
#

atf_test_case stamp_stable
stamp_stable_head() {
	atf_set "descr" "Stamp with stable output does not trigger rebuild"
}
stamp_stable_body() {
	cp -r "$(atf_get_srcdir)/examples/8_stamp_date" work
	cd work
	cat > expected.err <<'EOF'
ss: build build_date
ss: built build_date
ss: build hello
ss: built hello
ss: checksum build_date
ss: checksum hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	cat > expected.err <<'EOF'
ss: build build_date
ss: built build_date
ss: checksum hello
ss: checksum hello.c
ss: checksum build_date
ss: checksum build_date
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
}

atf_test_case stamp_changing
stamp_changing_head() {
	atf_set "descr" "Stamp with changing output triggers rebuild"
}
stamp_changing_body() {
	cp -r "$(atf_get_srcdir)/examples/9_stamp_time" work
	cd work
	cat > expected.err <<'EOF'
ss: build build_timestamp
ss: built build_timestamp
ss: build hello
ss: built hello
ss: checksum build_timestamp
ss: checksum hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	cat > expected.err <<'EOF'
ss: build build_timestamp
ss: built build_timestamp
ss: checksum hello
ss: checksum hello.c
ss: checksum build_timestamp
ss: build hello
ss: built hello
ss: checksum build_timestamp
ss: checksum hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
}

#
# target selection
#

atf_test_case named_file
named_file_head() {
	atf_set "descr" "Build from a named .ss file"
}
named_file_body() {
	cp -r "$(atf_get_srcdir)/examples/10_named_file" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d hello
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case select_targets
select_targets_head() {
	atf_set "descr" "Build only specified targets from all.ss"
}
select_targets_body() {
	cp -r "$(atf_get_srcdir)/examples/11_select_targets" work
	cd work
	cat > expected.err <<'EOF'
ss: build foo
ss: built foo
ss: build bar
ss: built bar
ss: checksum bar
ss: checksum bar.c
ss: checksum foo
ss: checksum foo.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d foo bar
	atf_check -s eq:0 -o inline:"foo\n" ./foo
	atf_check -s eq:0 -o inline:"bar\n" ./bar
	test ! -f baz
}

atf_test_case mixed_sources
mixed_sources_head() {
	atf_set "descr" "Source from named .ss files and fall back to all.ss"
}
mixed_sources_body() {
	cp -r "$(atf_get_srcdir)/examples/12_mixed_sources" work
	cd work
	cat > expected.err <<'EOF'
ss: build foo
ss: built foo
ss: build bar
ss: built bar
ss: checksum bar
ss: checksum bar.c
ss: checksum foo
ss: checksum foo.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d foo bar
	atf_check -s eq:0 -o inline:"foo\n" ./foo
	atf_check -s eq:0 -o inline:"bar\n" ./bar
}

#
# produces
#

atf_test_case produces
produces_head() {
	atf_set "descr" "Target produces output at a different path"
}
produces_body() {
	cp -r "$(atf_get_srcdir)/examples/13_produces" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello -> bin/hello
ss: built hello -> bin/hello
ss: checksum bin/hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	test ! -f hello
	atf_check -s eq:0 -o inline:"hello world\n" ./bin/hello
}

atf_test_case produces_multiple
produces_multiple_head() {
	atf_set "descr" "Single target with multiple produced outputs"
}
produces_multiple_body() {
	cp -r "$(atf_get_srcdir)/examples/14_produces_multiple" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello -> bin/hello
ss: built hello -> bin/hello
ss: checksum bin/hello
ss: checksum bin/hello.txt
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	test ! -f hello
	atf_check -s eq:0 -o inline:"hello world\n" ./bin/hello
	atf_check -s eq:0 -o inline:"built\n" cat bin/hello.txt
}

atf_test_case produces_rebuild_deleted
produces_rebuild_deleted_head() {
	atf_set "descr" "Deleting a secondary produced output triggers rebuild"
}
produces_rebuild_deleted_body() {
	cp -r "$(atf_get_srcdir)/examples/14_produces_multiple" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello -> bin/hello
ss: built hello -> bin/hello
ss: checksum bin/hello
ss: checksum bin/hello.txt
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	rm bin/hello.txt
	atf_check -s eq:0 -e file:expected.err ss -d
	test -f bin/hello.txt
}

atf_test_case produces_rebuild_modified
produces_rebuild_modified_head() {
	atf_set "descr" "Modifying a secondary produced output triggers rebuild"
}
produces_rebuild_modified_body() {
	cp -r "$(atf_get_srcdir)/examples/14_produces_multiple" work
	cd work
	atf_check -s eq:0 -e ignore ss -d
	echo "tampered" > bin/hello.txt
	cat > expected.err <<'EOF'
ss: checksum bin/hello
ss: checksum bin/hello.txt
ss: build hello -> bin/hello
ss: built hello -> bin/hello
ss: checksum bin/hello
ss: checksum bin/hello.txt
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"built\n" cat bin/hello.txt
}

atf_test_case produces_select
produces_select_head() {
	atf_set "descr" "Select a target by its produces path"
}
produces_select_body() {
	cp -r "$(atf_get_srcdir)/examples/15_produces_select" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello -> bin/hello
ss: built hello -> bin/hello
ss: checksum bin/hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d bin/hello
	atf_check -s eq:0 -o inline:"hello\n" ./bin/hello
	test ! -f bin/hello.txt
	test ! -f bin/goodbye
}

atf_test_case produces_ls
produces_ls_head() {
	atf_set "descr" "Produces paths shown indented under target in ls"
}
produces_ls_body() {
	cp -r "$(atf_get_srcdir)/examples/14_produces_multiple" work
	cd work
	cat > expected.out <<'EOF'
hello
  bin/hello
  bin/hello.txt
EOF
	atf_check -s eq:0 -o file:expected.out ss ls
}

atf_test_case produces_clean
produces_clean_head() {
	atf_set "descr" "Clean removes all produced files"
}
produces_clean_body() {
	cp -r "$(atf_get_srcdir)/examples/14_produces_multiple" work
	cd work
	atf_check -s eq:0 ss
	test -f bin/hello
	test -f bin/hello.txt
	atf_check -s eq:0 ss clean
	test ! -f bin/hello
	test ! -f bin/hello.txt
}

atf_test_case produces_checksum_consumer
produces_checksum_consumer_head() {
	atf_set "descr" "Modified produces triggers producer rebuild, consumer stays clean"
}
produces_checksum_consumer_body() {
	cp -r "$(atf_get_srcdir)/examples/16_produces_checksum_consumer" work
	cd work

	# first build - both build
	cat > expected_first.err <<'EOF'
ss: build foo -> foo.txt
ss: built foo -> foo.txt
ss: build bar -> out.txt
ss: built bar -> out.txt
ss: checksum out.txt
ss: checksum bar.txt
ss: checksum foo.txt
ss: checksum bar.txt
ss: checksum foo.c
EOF
	atf_check -s eq:0 -e file:expected_first.err ss -d
	atf_check -s eq:0 -o inline:"bar\n" cat out.txt

	# no changes - neither builds
	cat > expected_clean.err <<'EOF'
ss: checksum foo.txt
ss: checksum bar.txt
ss: checksum foo.c
ss: checksum out.txt
ss: checksum bar.txt
EOF
	atf_check -s eq:0 -e file:expected_clean.err ss -d

	# modify bar.txt externally - foo rebuilds to restore it,
	# bar does not rebuild because bar.txt is restored
	echo "new bar" > bar.txt
	cat > expected_modified.err <<'EOF'
ss: checksum foo.txt
ss: checksum bar.txt
ss: build foo -> foo.txt
ss: built foo -> foo.txt
ss: checksum out.txt
ss: checksum bar.txt
ss: checksum foo.txt
ss: checksum bar.txt
ss: checksum foo.c
EOF

	atf_check -s eq:0 -e file:expected_modified.err ss -d
	atf_check -s eq:0 -o inline:"bar\n" cat out.txt
}

#
# out-of-tree
#

atf_test_case outdir_not_enabled
outdir_not_enabled_head() {
	atf_set "descr" "Out-of-tree target builds in-tree when not enabled"
}
outdir_not_enabled_body() {
	cp -r "$(atf_get_srcdir)/examples/17_outdir" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case outdir_enabled
outdir_enabled_head() {
	atf_set "descr" "Out-of-tree target builds into outdir"
}
outdir_enabled_body() {
	cp -r "$(atf_get_srcdir)/examples/17_outdir" work
	cd work
	cat > expected.err <<EOF
ss: build hello -> ${TMPDIR}/_build/hello
ss: built hello -> ${TMPDIR}/_build/hello
ss: checksum ${TMPDIR}/_build/hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d -o ${TMPDIR}/_build
	test ! -f hello
	atf_check -s eq:0 -o inline:"hello world\n" ${TMPDIR}/_build/hello

	cat > expected.err <<EOF
ss: checksum ${TMPDIR}/_build/hello
ss: checksum hello.c
EOF
	atf_check -s eq:0 -e file:expected.err ss -d -o ${TMPDIR}/_build
}

atf_test_case outdir_multiple
outdir_multiple_head() {
	atf_set "descr" "Multiple out-of-tree targets build into outdir"
}
outdir_multiple_body() {
	cp -r "$(atf_get_srcdir)/examples/18_outdir_multiple" work
	cd work
	cat > expected.err <<EOF
ss: build libhello.o -> ${TMPDIR}/_build/libhello.o
ss: built libhello.o -> ${TMPDIR}/_build/libhello.o
ss: build hello -> ${TMPDIR}/_build/hello
ss: built hello -> ${TMPDIR}/_build/hello
ss: checksum ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum libhello.c
ss: checksum ${TMPDIR}/_build/libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d -o ${TMPDIR}/_build
	test ! -f libhello.o
	test ! -f hello
	test -f ${TMPDIR}/_build/libhello.o
	atf_check -s eq:0 -o inline:"hello world\n" ${TMPDIR}/_build/hello

	cat > expected.err <<EOF
ss: checksum ${TMPDIR}/_build/libhello.o
ss: checksum libhello.c
ss: checksum ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum ${TMPDIR}/_build/libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d -o ${TMPDIR}/_build
}

atf_test_case outdir_mixed
outdir_mixed_head() {
	atf_set "descr" "Mix of in-tree and out-of-tree targets"
}
outdir_mixed_body() {
	cp -r "$(atf_get_srcdir)/examples/19_outdir_mixed" work
	cd work
	echo "hello world" > ${TMPDIR}/new-greeting
	cat > expected.err <<EOF
ss: build greeting -> ${TMPDIR}/_build/greeting
ss: built greeting -> ${TMPDIR}/_build/greeting
ss: build libhello.o
ss: built libhello.o
ss: build hello -> ${TMPDIR}/_build/hello
ss: built hello -> ${TMPDIR}/_build/hello
ss: checksum ${TMPDIR}/new-greeting
ss: checksum ${TMPDIR}/_build/greeting
ss: checksum ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum libhello.in
ss: checksum libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d -o ${TMPDIR}/_build
	test -f ${TMPDIR}/_build/greeting
	test ! -f greeting
	test -f libhello.o
	test ! -f ${TMPDIR}/_build/libhello.o
	test ! -f hello
	atf_check -s eq:0 -o inline:"hello world\n" ${TMPDIR}/_build/hello

	cat > expected.err <<EOF
ss: checksum ${TMPDIR}/_build/greeting
ss: checksum ${TMPDIR}/new-greeting
ss: checksum libhello.o
ss: checksum libhello.in
ss: checksum ${TMPDIR}/_build/greeting
ss: checksum ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d -o ${TMPDIR}/_build

	echo "hello ss" > ${TMPDIR}/new-greeting
	cat > expected.err <<EOF
ss: checksum ${TMPDIR}/_build/greeting
ss: checksum ${TMPDIR}/new-greeting
ss: build greeting -> ${TMPDIR}/_build/greeting
ss: built greeting -> ${TMPDIR}/_build/greeting
ss: checksum libhello.o
ss: checksum libhello.in
ss: checksum ${TMPDIR}/_build/greeting
ss: build libhello.o
ss: built libhello.o
ss: checksum ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum libhello.o
ss: build hello -> ${TMPDIR}/_build/hello
ss: built hello -> ${TMPDIR}/_build/hello
ss: checksum ${TMPDIR}/new-greeting
ss: checksum ${TMPDIR}/_build/greeting
ss: checksum ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum libhello.in
ss: checksum libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d -o ${TMPDIR}/_build
	atf_check -s eq:0 -o inline:"hello ss\n" ${TMPDIR}/_build/hello
}

#
# listing and clean
#

atf_test_case ls_targets
ls_targets_head() {
	atf_set "descr" "List available targets without building"
}
ls_targets_body() {
	cp -r "$(atf_get_srcdir)/examples/19_outdir_mixed" work
	cd work
	echo "hello world" > ${TMPDIR}/new-greeting
	cat > expected.out <<'EOF'
greeting
libhello.o
hello
EOF
	atf_check -s eq:0 -o file:expected.out ss ls
	test ! -f greeting
	test ! -f libhello.o
	test ! -f hello
}

atf_test_case clean
clean_head() {
	atf_set "descr" "Clean removes built target files"
}
clean_body() {
	cp -r "$(atf_get_srcdir)/examples/4_multiple_targets" work
	cd work
	atf_check -s eq:0 ss
	test -f hello
	test -f libhello.o
	atf_check -s eq:0 ss clean
	test ! -f hello
	test ! -f libhello.o
	test -f hello.c
	test -f libhello.c
}

atf_test_case clean_selective
clean_selective_head() {
	atf_set "descr" "Clean with targets removes only those targets"
}
clean_selective_body() {
	cp -r "$(atf_get_srcdir)/examples/11_select_targets" work
	cd work
	atf_check -s eq:0 ss
	test -f foo
	test -f bar
	test -f baz
	atf_check -s eq:0 ss clean foo bar
	test ! -f foo
	test ! -f bar
	test -f baz
	atf_check -s eq:0 ss clean foo bar
}

#
# errors
#

atf_test_case unknown_command
unknown_command_head() {
	atf_set "descr" "Unknown command prints error and exits"
}
unknown_command_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:1 -e inline:"ss: E: unknown target: bogus\n" ss bogus
	test ! -f hello
}

atf_test_case bad_flag
bad_flag_head() {
	atf_set "descr" "Unknown flag prints error and exits"
}
bad_flag_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:1 -e inline:"ss: E: unknown option: -h\n" ss -h
	atf_check -s eq:1 -e inline:"ss: E: unknown option: -h\n" ss -h foo
	atf_check -s eq:1 -e inline:"ss: E: unknown option: --\n" ss --help
	test ! -f hello
}

atf_test_case failed_dep
failed_dep_head() {
	atf_set "descr" "Failed dep aborts build before downstream targets"
}
failed_dep_body() {
	cp -r "$(atf_get_srcdir)/examples/23_failed_dep" work
	cd work
	ss -d 2>build.err; test $? -ne 0
	grep '^ss: ' build.err > ss.err
	cat > expected.err <<'EOF'
ss: build libhello.o
ss: E: libhello.o
EOF
	atf_check -o file:expected.err cat ss.err
	test ! -f libhello.o
	test ! -f hello
}

atf_test_case failed_downstream
failed_downstream_head() {
	atf_set "descr" "Successful dep not rebuilt when downstream fails"
}
failed_downstream_body() {
	cp -r "$(atf_get_srcdir)/examples/24_failed_downstream" work
	cd work
	ss -d 2>build.err; test $? -ne 0
	grep '^ss: ' build.err > ss.err
	cat > expected.err <<'EOF'
ss: build libhello.o
ss: built libhello.o
ss: build hello
ss: E: hello
ss: checksum libhello.c
ss: checksum libhello.o
EOF
	atf_check -o file:expected.err cat ss.err
	test -f libhello.o
	test ! -f hello

	ss -d 2>build.err; test $? -ne 0
	grep '^ss: ' build.err > ss.err
	cat > expected.err <<'EOF'
ss: checksum libhello.o
ss: checksum libhello.c
ss: build hello
ss: E: hello
EOF
	atf_check -o file:expected.err cat ss.err
}

atf_test_case missing_dep
missing_dep_head() {
	atf_set "descr" "Missing dep without build rule prints diagnostic"
}
missing_dep_body() {
	cp -r "$(atf_get_srcdir)/examples/25_missing_dep" work
	cd work
	ss 2>err.out; test $? -ne 0
	atf_check -o inline:"ss: E: missing source: missing.h\n" cat err.out
	test ! -f hello
}

atf_test_case cycle
cycle_head() {
	atf_set "descr" "Circular dependency prints diagnostic"
}
cycle_body() {
	cp -r "$(atf_get_srcdir)/examples/26_cycle" work
	cd work
	ss 2>err.out; test $? -ne 0
	atf_check -o inline:"ss: E: cycle: a\n" cat err.out
	test ! -f a
	test ! -f b
}

atf_test_case missing_output
missing_output_head() {
	atf_set "descr" "Build that does not produce its target fails"
}
missing_output_body() {
	cp -r "$(atf_get_srcdir)/examples/27_missing_output" work
	cd work
	ss 2>err.out; test $? -ne 0
	atf_check -o inline:"ss: E: hello: build did not produce hello\n" cat err.out
	test ! -f hello
}

atf_test_case produces_missing
produces_missing_head() {
	atf_set "descr" "Build that does not produce declared output fails"
}
produces_missing_body() {
	cp -r "$(atf_get_srcdir)/examples/28_produces_missing" work
	cd work
	ss 2>err.out; test $? -ne 0
	atf_check -o inline:"ss: E: hello: build did not produce bin/hello\n" cat err.out
	test ! -f bin/hello
}

atf_test_case produces_conflict_dup
produces_conflict_dup_head() {
	atf_set "descr" "Duplicate target detected as conflicting produces"
}
produces_conflict_dup_body() {
	cp -r "$(atf_get_srcdir)/examples/29_produces_conflict_dup" work
	cd work
	atf_check -s eq:1 \
		-e inline:"ss: E: conflicting produces: foo and foo both produce foo\n" \
		ss
}

atf_test_case produces_conflict_explicit
produces_conflict_explicit_head() {
	atf_set "descr" "Two targets with same explicit produces path"
}
produces_conflict_explicit_body() {
	cp -r "$(atf_get_srcdir)/examples/30_produces_conflict_explicit" work
	cd work
	atf_check -s eq:1 \
		-e inline:"ss: E: conflicting produces: foo and bar both produce out.txt\n" \
		ss
}

atf_test_case produces_conflict_implicit
produces_conflict_implicit_head() {
	atf_set "descr" "Explicit produces conflicts with implicit target output"
}
produces_conflict_implicit_body() {
	cp -r "$(atf_get_srcdir)/examples/31_produces_conflict_implicit" work
	cd work
	atf_check -s eq:1 \
		-e inline:"ss: E: conflicting produces: foo and bar both produce foo\n" \
		ss
}

atf_test_case produces_conflict_multiple
produces_conflict_multiple_head() {
	atf_set "descr" "Multiple produces with one overlapping path"
}
produces_conflict_multiple_body() {
	cp -r "$(atf_get_srcdir)/examples/32_produces_conflict_multiple" work
	cd work
	atf_check -s eq:1 \
		-e inline:"ss: E: conflicting produces: foo and bar both produce a\n" \
		ss
}

atf_test_case produces_conflict_target_name
produces_conflict_target_name_head() {
	atf_set "descr" "Produces path conflicts with another target name"
}
produces_conflict_target_name_body() {
	cp -r "$(atf_get_srcdir)/examples/33_produces_conflict_target_name" work
	cd work
	atf_check -s eq:1 \
		-e inline:"ss: E: conflicting produces: foo and bar both produce foo\n" \
		ss
}

atf_test_case clean_unknown_target
clean_unknown_target_head() {
	atf_set "descr" "Clean with unknown target prints error"
}
clean_unknown_target_body() {
	cp -r "$(atf_get_srcdir)/examples/4_multiple_targets" work
	cd work
	atf_check -s eq:1 -e inline:"ss: E: unknown target: bogus\n" ss clean bogus
}

#
# edge cases
#

atf_test_case colon_target
colon_target_head() {
	atf_set "descr" "Target name with colon"
}
colon_target_body() {
	cp -r "$(atf_get_srcdir)/examples/20_colon_target" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello:world
ss: built hello:world
ss: checksum hello.c
ss: checksum hello:world
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" "./hello:world"
}

atf_test_case slash_dep
slash_dep_head() {
	atf_set "descr" "Dependency with slash in path"
}
slash_dep_body() {
	cp -r "$(atf_get_srcdir)/examples/21_slash_dep" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
ss: checksum inc/hello.h
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	sed -i '' 's/hello world/hello ss/' inc/hello.h

	cat > expected.err <<'EOF'
ss: checksum hello
ss: checksum hello.c
ss: checksum inc/hello.h
ss: build hello
ss: built hello
ss: checksum hello
ss: checksum hello.c
ss: checksum inc/hello.h
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello ss\n" ./hello
}

atf_test_case target_vs_outfile
target_vs_outfile_head() {
	atf_set "descr" "Build function receives target name and outfile path"
}
target_vs_outfile_body() {
	cp -r "$(atf_get_srcdir)/examples/22_target_vs_outfile" work
	cd work
	atf_check -s eq:0 ss -o ${TMPDIR}/_build
	test ! -f hello
	atf_check -s eq:0 -o inline:"hello\n" cat ${TMPDIR}/_build/hello
}

atf_test_case deps_dir_per_cwd
deps_dir_per_cwd_head() {
	atf_set "descr" "Dep checksums stored under TMPDIR with CWD path"
}
deps_dir_per_cwd_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	ss -d
	test -f "${TMPDIR}/ss/$(pwd)/hello"
}
