target foo
produces a b

foo() {
	echo foo > a
	echo foo > b
}

target bar
produces c a

bar() {
	echo bar > c
	echo bar > a
}
