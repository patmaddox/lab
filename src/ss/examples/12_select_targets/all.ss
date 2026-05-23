target foo
needs foo.c

target bar
needs bar.c

target baz
needs baz.c

foo() {
	cc -o ${target} ${deps}
}

bar() {
	cc -o ${target} ${deps}
}

baz() {
	cc -o ${target} ${deps}
}
