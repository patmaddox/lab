target hello
needs hello.c libhello.o

target libhello.o libhello
needs libhello.c

libhello() {
	cc -c -o ${outfile} ${deps}
}

hello() {
	cc -o ${outfile} ${deps}
}
