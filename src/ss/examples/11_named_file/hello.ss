target hello
needs hello.c

hello() {
	cc -o ${target} ${deps}
}
