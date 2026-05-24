target hello
needs hello.c
produces bin/hello

hello() {
	cc -o hello ${deps}
}
