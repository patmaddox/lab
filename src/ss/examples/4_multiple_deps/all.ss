target hello
needs hello.c libhello.c

hello() {
	cc -o ${target} ${deps}
}
