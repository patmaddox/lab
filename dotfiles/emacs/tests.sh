#!/usr/bin/env atf-sh
src_dir=$(atf_get_srcdir)

atf_init_test_cases() {
    atf_add_test_case install_and_load
    atf_add_test_case format_c
    atf_add_test_case format_cmake
    atf_add_test_case format_cpp
    atf_add_test_case format_css
    atf_add_test_case format_dockerfile
    atf_add_test_case format_elixir
    atf_add_test_case format_elixir_script
    atf_add_test_case format_go
    atf_add_test_case format_heex
    atf_add_test_case format_html
    atf_add_test_case format_java
    atf_add_test_case format_js
    atf_add_test_case format_json
    atf_add_test_case format_lua
    atf_add_test_case format_makefile
    atf_add_test_case format_markdown
    atf_add_test_case format_python
    atf_add_test_case format_ruby
    atf_add_test_case format_rust
    atf_add_test_case format_sh
    atf_add_test_case format_toml
    atf_add_test_case format_typescript
    atf_add_test_case format_tsx
    atf_add_test_case format_yaml
}

helper::install() {
    atf_check -o ignore env INSTALL_AS_USER=yes pkg -r ${HOME} add ${src_dir}/patmaddox-emacs.pkg
}

helper::check_mode() {
    file="$1"
    mode="$2"
    noformatter="$3"
    if [ "$noformatter" = "noformatter" ]; then
	atf_check -o ignore -e ignore emacs --batch \
	    -l ${src_dir}/test-init.el \
	    -l ${HOME}/.emacs.d/init.el \
	    -eval "(test-file-no-formatter \"${file}\" '${mode})"
    else
	atf_check -o ignore -e ignore emacs --batch \
	    -l ${src_dir}/test-init.el \
	    -l ${HOME}/.emacs.d/init.el \
	    -eval "(test-file \"${file}\" '${mode})"
    fi
}

helper::check_format_on_save() {
    file="$1"
    mode="$2"
    filename=$(basename "$file")
    cp "${file}" "${TMPDIR}/${filename}"
    atf_check -o ignore -e ignore emacs --batch \
	-l ${src_dir}/test-init.el \
	-l ${HOME}/.emacs.d/init.el \
	-eval "(test-file-format-on-save \"${TMPDIR}/${filename}\" '${mode})"
}

## install_and_load
atf_test_case install_and_load
install_and_load_head() {
    atf_set 'descr' 'Install config file and compiled packages to $HOME/.emacs.d, load init.el, check modes and stuff'
}

install_and_load_body() {
    helper::install

    atf_check test -d ${HOME}/.emacs.d
    atf_check test -f ${HOME}/.emacs.d/init.el
    atf_check test ! -f ${HOME}/.emacs.d/init.elc

    # verify init.el loads without error
    atf_check -o ignore -e ignore emacs --batch \
	      -l ${src_dir}/test-init.el \
	      -l ${HOME}/.emacs.d/init.el
}

## format_c
atf_test_case format_c
format_c_head() {
    atf_set 'descr' 'Verify C formatter matches FreeBSD style(9)'
}
format_c_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.c c-ts-mode
}

## format_sh
atf_test_case format_sh
format_sh_head() {
    atf_set 'descr' 'Verify shell formatter matches FreeBSD style'
}
format_sh_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.sh bash-ts-mode
}

## format_cmake
atf_test_case format_cmake
format_cmake_head() {
    atf_set 'descr' 'Verify CMake formatter'
}
format_cmake_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/CMakeLists.txt cmake-ts-mode
}

## format_cpp
atf_test_case format_cpp
format_cpp_head() {
    atf_set 'descr' 'Verify C++ formatter'
}
format_cpp_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.cpp c++-ts-mode
}

## format_css
atf_test_case format_css
format_css_head() {
    atf_set 'descr' 'Verify CSS formatter'
}
format_css_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.css css-ts-mode
}

## format_dockerfile
atf_test_case format_dockerfile
format_dockerfile_head() {
    atf_set 'descr' 'Verify Dockerfile formatter'
}
format_dockerfile_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/Dockerfile dockerfile-ts-mode
}

## format_elixir
atf_test_case format_elixir
format_elixir_head() {
    atf_set 'descr' 'Verify Elixir mode and format-on-save'
}
format_elixir_body() {
    helper::install
    helper::check_format_on_save ${src_dir}/examples/example.ex elixir-ts-mode
}

## format_elixir_script
atf_test_case format_elixir_script
format_elixir_script_head() {
    atf_set 'descr' 'Verify Elixir script mode and format-on-save'
}
format_elixir_script_body() {
    helper::install
    helper::check_format_on_save ${src_dir}/examples/example.exs elixir-ts-mode
}

## format_go
atf_test_case format_go
format_go_head() {
    atf_set 'descr' 'Verify Go formatter'
}
format_go_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.go go-ts-mode
}

## format_heex
atf_test_case format_heex
format_heex_head() {
    atf_set 'descr' 'Verify HEEx mode and format-on-save'
}
format_heex_body() {
    helper::install
    helper::check_format_on_save ${src_dir}/examples/example.heex heex-ts-mode
}

## format_html
atf_test_case format_html
format_html_head() {
    atf_set 'descr' 'Verify HTML formatter'
}
format_html_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.html html-ts-mode
}

## format_java
atf_test_case format_java
format_java_head() {
    atf_set 'descr' 'Verify Java formatter'
}
format_java_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.java java-ts-mode
}

## format_js
atf_test_case format_js
format_js_head() {
    atf_set 'descr' 'Verify JavaScript formatter'
}
format_js_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.js js-ts-mode
}

## format_json
atf_test_case format_json
format_json_head() {
    atf_set 'descr' 'Verify JSON formatter'
}
format_json_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.json json-ts-mode
}

## format_lua
atf_test_case format_lua
format_lua_head() {
    atf_set 'descr' 'Verify Lua formatter'
}
format_lua_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.lua lua-ts-mode
}

## format_makefile
atf_test_case format_makefile
format_makefile_head() {
    atf_set 'descr' 'Verify Makefile mode and formatter'
}
format_makefile_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.mk makefile-bsdmake-mode noformatter
}

## format_markdown
atf_test_case format_markdown
format_markdown_head() {
    atf_set 'descr' 'Verify Markdown formatter'
}
format_markdown_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.md gfm-mode
}

## format_python
atf_test_case format_python
format_python_head() {
    atf_set 'descr' 'Verify Python formatter'
}
format_python_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.py python-ts-mode
}

## format_ruby
atf_test_case format_ruby
format_ruby_head() {
    atf_set 'descr' 'Verify Ruby formatter'
}
format_ruby_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.rb ruby-ts-mode
}

## format_rust
atf_test_case format_rust
format_rust_head() {
    atf_set 'descr' 'Verify Rust formatter'
}
format_rust_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.rs rust-ts-mode
}

## format_toml
atf_test_case format_toml
format_toml_head() {
    atf_set 'descr' 'Verify TOML formatter'
}
format_toml_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.toml toml-ts-mode
}

## format_typescript
atf_test_case format_typescript
format_typescript_head() {
    atf_set 'descr' 'Verify TypeScript formatter'
}
format_typescript_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.ts typescript-ts-mode
}

## format_tsx
atf_test_case format_tsx
format_tsx_head() {
    atf_set 'descr' 'Verify TSX formatter'
}
format_tsx_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.tsx tsx-ts-mode
}

## format_yaml
atf_test_case format_yaml
format_yaml_head() {
    atf_set 'descr' 'Verify YAML formatter'
}
format_yaml_body() {
    helper::install
    helper::check_mode ${src_dir}/examples/example.yaml yaml-ts-mode noformatter
}
