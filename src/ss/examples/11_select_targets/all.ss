target foo
needs foo.c

target bar
needs bar.c

target baz
needs baz.c

foo() {
	cc -o ${outfile} ${deps}
}

bar() {
	cc -o ${outfile} ${deps}
}

baz() {
	cc -o ${outfile} ${deps}
}
