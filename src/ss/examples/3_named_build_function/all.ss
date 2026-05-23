target hello.out build_hello
needs hello.c

build_hello() {
	cc -o ${target} ${deps}
}
