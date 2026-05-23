target hello
needs hello.c libhello.c

hello() {
	cc -o ${outfile} ${deps}
}
