target hello
needs hello.c

hello() {
	cc -o ${outfile} ${deps}
}
