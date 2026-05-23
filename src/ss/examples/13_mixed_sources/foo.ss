target foo
needs foo.c

foo() {
	cc -o ${target} ${deps}
}
