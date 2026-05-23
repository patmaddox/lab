target foo
needs foo.c

foo() {
	cc -o ${outfile} ${deps}
}
