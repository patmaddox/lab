target libhello.o libhello
needs libhello.c

target hello
needs hello.c libhello.o

libhello() {
	cc -c -o ${target} ${deps}
}

hello() {
	cc -o ${target} ${deps}
}
