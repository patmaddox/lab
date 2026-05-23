target hello
needs hello.c

hello() {
	cc -o hello hello.c
}
