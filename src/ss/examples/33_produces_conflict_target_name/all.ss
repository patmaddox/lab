target foo
produces output.txt

foo() {
	echo foo > output.txt
}

target bar
produces foo

bar() {
	echo bar > foo
}
