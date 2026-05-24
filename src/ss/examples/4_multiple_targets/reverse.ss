target libhello.o libhello
needs libhello.c

target hello
needs hello.c libhello.o

libhello() {
	cc -c -o ${outfile} ${deps}
}

hello() {
	cc -o ${outfile} ${deps}
}
