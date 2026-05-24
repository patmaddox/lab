target foo

foo() {
	echo foo > "${outfile}"
}

target bar
produces foo

bar() {
	echo bar > foo
}
