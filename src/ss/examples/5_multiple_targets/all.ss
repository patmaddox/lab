target hello
needs hello.c libhello.o

target libhello.o libhello
needs libhello.c

libhello() {
	cc -c -o ${target} ${deps}
}

hello() {
	cc -o ${target} ${deps}
}
