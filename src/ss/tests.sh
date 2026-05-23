#!/usr/bin/env atf-sh

export PATH=$(atf_get_srcdir):$PATH

atf_init_test_cases() {
	atf_add_test_case hello_world
	atf_add_test_case hello_world_silent
	atf_add_test_case hello_world_rebuild_clean
	atf_add_test_case hello_world_rebuild_dirty
	atf_add_test_case hello_world_vars
	atf_add_test_case named_build_function
	atf_add_test_case multiple_deps
	atf_add_test_case multiple_targets
	atf_add_test_case multiple_targets_reverse
	atf_add_test_case implicit_deps
	atf_add_test_case implicit_deps_rebuild
	atf_add_test_case stamp_stable
	atf_add_test_case stamp_changing
	atf_add_test_case deps_dir_per_cwd
	atf_add_test_case colon_target
	atf_add_test_case named_file
	atf_add_test_case select_targets
	atf_add_test_case mixed_sources
	atf_add_test_case slash_dep
	atf_add_test_case outdir_not_enabled
	atf_add_test_case outdir_enabled
	atf_add_test_case outdir_multiple
	atf_add_test_case outdir_mixed
	atf_add_test_case ls_targets
	atf_add_test_case unknown_command
	atf_add_test_case bad_flag
	atf_add_test_case failed_dep
	atf_add_test_case failed_downstream
	atf_add_test_case target_vs_outfile
}

atf_test_case hello_world
hello_world_head() {
	atf_set "descr" "Build a target with explicit commands"
}
hello_world_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case hello_world_silent
hello_world_silent_head() {
	atf_set "descr" "Successful build produces no output without -d"
}
hello_world_silent_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:0 -o empty -e empty ss
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case hello_world_rebuild_clean
hello_world_rebuild_clean_head() {
	atf_set "descr" "Rebuild a target with no changed deps"
}
hello_world_rebuild_clean_body() {
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

atf_test_case hello_world_rebuild_dirty
hello_world_rebuild_dirty_head() {
	atf_set "descr" "Rebuild a target with a changed dep"
}
hello_world_rebuild_dirty_body() {
	cp -r "$(atf_get_srcdir)/examples/1_hello_world" work
	cd work
	atf_check -s eq:0 -e ignore ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello

	sed -i -e 's/world/ss/' hello.c

	cat > expected.err <<'EOF'
ss: checksum hello
ss: checksum hello.c
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello ss\n" ./hello
}

atf_test_case hello_world_vars
hello_world_vars_head() {
	atf_set "descr" "Build a target using framework vars"
}
hello_world_vars_body() {
	cp -r "$(atf_get_srcdir)/examples/2_hello_world_vars" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case named_build_function
named_build_function_head() {
	atf_set "descr" "Target with a named build function"
}
named_build_function_body() {
	cp -r "$(atf_get_srcdir)/examples/3_named_build_function" work
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

atf_test_case multiple_deps
multiple_deps_head() {
	atf_set "descr" "Target with multiple dependencies"
}
multiple_deps_body() {
	cp -r "$(atf_get_srcdir)/examples/4_multiple_deps" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum libhello.c
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case multiple_targets
multiple_targets_head() {
	atf_set "descr" "Multiple targets with dependency ordering"
}
multiple_targets_body() {
	cp -r "$(atf_get_srcdir)/examples/5_multiple_targets" work
	cd work
	cat > expected.err <<'EOF'
ss: build libhello.o
ss: built libhello.o
ss: checksum libhello.c
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum libhello.o
ss: checksum hello
ss: checksum libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case multiple_targets_reverse
multiple_targets_reverse_head() {
	atf_set "descr" "Multiple targets with reverse declaration order"
}
multiple_targets_reverse_body() {
	cp -r "$(atf_get_srcdir)/examples/6_multiple_targets_reverse" work
	cd work
	cat > expected.err <<'EOF'
ss: build libhello.o
ss: built libhello.o
ss: checksum libhello.c
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum libhello.o
ss: checksum hello
ss: checksum libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case implicit_deps
implicit_deps_head() {
	atf_set "descr" "Implicit deps excluded from deps var"
}
implicit_deps_body() {
	cp -r "$(atf_get_srcdir)/examples/7_implicit_deps" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum hello.h
ss: checksum note.txt
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case implicit_deps_rebuild
implicit_deps_rebuild_head() {
	atf_set "descr" "Changing an implicit dep triggers rebuild"
}
implicit_deps_rebuild_body() {
	cp -r "$(atf_get_srcdir)/examples/7_implicit_deps" work
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
ss: checksum hello.c
ss: checksum hello.h
ss: checksum note.txt
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello ss\n" ./hello
}

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
ss: checksum hello.c
ss: checksum build_date
ss: checksum build_date
ss: checksum hello
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
ss: checksum hello.c
ss: checksum build_timestamp
ss: checksum build_timestamp
ss: checksum hello
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
ss: checksum hello.c
ss: checksum build_timestamp
ss: checksum build_timestamp
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
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

atf_test_case colon_target
colon_target_head() {
	atf_set "descr" "Target name with colon"
}
colon_target_body() {
	cp -r "$(atf_get_srcdir)/examples/10_colon_target" work
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

atf_test_case named_file
named_file_head() {
	atf_set "descr" "Build from a named .ss file"
}
named_file_body() {
	cp -r "$(atf_get_srcdir)/examples/11_named_file" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d hello
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case select_targets
select_targets_head() {
	atf_set "descr" "Build only specified targets from all.ss"
}
select_targets_body() {
	cp -r "$(atf_get_srcdir)/examples/12_select_targets" work
	cd work
	cat > expected.err <<'EOF'
ss: build foo
ss: built foo
ss: checksum foo.c
ss: build bar
ss: built bar
ss: checksum bar.c
ss: checksum bar
ss: checksum foo
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
	cp -r "$(atf_get_srcdir)/examples/13_mixed_sources" work
	cd work
	cat > expected.err <<'EOF'
ss: build foo
ss: built foo
ss: checksum foo.c
ss: build bar
ss: built bar
ss: checksum bar.c
ss: checksum bar
ss: checksum foo
EOF
	atf_check -s eq:0 -e file:expected.err ss -d foo bar
	atf_check -s eq:0 -o inline:"foo\n" ./foo
	atf_check -s eq:0 -o inline:"bar\n" ./bar
}

atf_test_case slash_dep
slash_dep_head() {
	atf_set "descr" "Dependency with slash in path"
}
slash_dep_body() {
	cp -r "$(atf_get_srcdir)/examples/14_slash_dep" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum inc/hello.h
ss: checksum hello
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
ss: checksum hello.c
ss: checksum inc/hello.h
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello ss\n" ./hello
}

atf_test_case outdir_not_enabled
outdir_not_enabled_head() {
	atf_set "descr" "Out-of-tree target builds in-tree when not enabled"
}
outdir_not_enabled_body() {
	cp -r "$(atf_get_srcdir)/examples/15_outdir" work
	cd work
	cat > expected.err <<'EOF'
ss: build hello
ss: built hello
ss: checksum hello.c
ss: checksum hello
EOF
	atf_check -s eq:0 -e file:expected.err ss -d
	atf_check -s eq:0 -o inline:"hello world\n" ./hello
}

atf_test_case outdir_enabled
outdir_enabled_head() {
	atf_set "descr" "Out-of-tree target builds into outdir"
}
outdir_enabled_body() {
	cp -r "$(atf_get_srcdir)/examples/15_outdir" work
	cd work
	cat > expected.err <<EOF
ss: build hello -> ${TMPDIR}/_build/hello
ss: built hello -> ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum ${TMPDIR}/_build/hello
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
	cp -r "$(atf_get_srcdir)/examples/16_outdir_multiple" work
	cd work
	cat > expected.err <<EOF
ss: build libhello.o -> ${TMPDIR}/_build/libhello.o
ss: built libhello.o -> ${TMPDIR}/_build/libhello.o
ss: checksum libhello.c
ss: build hello -> ${TMPDIR}/_build/hello
ss: built hello -> ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum ${TMPDIR}/_build/libhello.o
ss: checksum ${TMPDIR}/_build/hello
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
	cp -r "$(atf_get_srcdir)/examples/17_outdir_mixed" work
	cd work
	echo "hello world" > ${TMPDIR}/new-greeting
	cat > expected.err <<EOF
ss: build greeting -> ${TMPDIR}/_build/greeting
ss: built greeting -> ${TMPDIR}/_build/greeting
ss: checksum ${TMPDIR}/new-greeting
ss: build libhello.o
ss: built libhello.o
ss: checksum libhello.in
ss: checksum ${TMPDIR}/_build/greeting
ss: build hello -> ${TMPDIR}/_build/hello
ss: built hello -> ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum libhello.o
ss: checksum ${TMPDIR}/_build/greeting
ss: checksum ${TMPDIR}/_build/hello
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
ss: checksum ${TMPDIR}/new-greeting
ss: checksum libhello.o
ss: checksum libhello.in
ss: checksum ${TMPDIR}/_build/greeting
ss: build libhello.o
ss: built libhello.o
ss: checksum libhello.in
ss: checksum ${TMPDIR}/_build/greeting
ss: checksum ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum libhello.o
ss: build hello -> ${TMPDIR}/_build/hello
ss: built hello -> ${TMPDIR}/_build/hello
ss: checksum hello.c
ss: checksum libhello.o
ss: checksum ${TMPDIR}/_build/greeting
ss: checksum ${TMPDIR}/_build/hello
ss: checksum libhello.o
EOF
	atf_check -s eq:0 -e file:expected.err ss -d -o ${TMPDIR}/_build
	atf_check -s eq:0 -o inline:"hello ss\n" ${TMPDIR}/_build/hello
}

atf_test_case ls_targets
ls_targets_head() {
	atf_set "descr" "List available targets without building"
}
ls_targets_body() {
	cp -r "$(atf_get_srcdir)/examples/17_outdir_mixed" work
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
	cp -r "$(atf_get_srcdir)/examples/18_failed_dep" work
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
	cp -r "$(atf_get_srcdir)/examples/19_failed_downstream" work
	cd work
	ss -d 2>build.err; test $? -ne 0
	grep '^ss: ' build.err > ss.err
	cat > expected.err <<'EOF'
ss: build libhello.o
ss: built libhello.o
ss: checksum libhello.c
ss: build hello
ss: E: hello
EOF
	atf_check -o file:expected.err cat ss.err
	test -f libhello.o
	test ! -f hello

	ss -d 2>build.err; test $? -ne 0
	grep '^ss: ' build.err > ss.err
	cat > expected.err <<'EOF'
ss: build libhello.o
ss: built libhello.o
ss: checksum libhello.c
ss: build hello
ss: E: hello
EOF
	atf_check -o file:expected.err cat ss.err
}

atf_test_case target_vs_outfile
target_vs_outfile_head() {
	atf_set "descr" "Build function receives target name and outfile path"
}
target_vs_outfile_body() {
	cp -r "$(atf_get_srcdir)/examples/20_target_vs_outfile" work
	cd work
	atf_check -s eq:0 ss -o ${TMPDIR}/_build
	test ! -f hello
	atf_check -s eq:0 -o inline:"hello\n" cat ${TMPDIR}/_build/hello
}
