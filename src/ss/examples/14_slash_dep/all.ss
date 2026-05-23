target hello
needs hello.c : inc/hello.h

hello() {
	cc -o ${target} ${deps}
}
