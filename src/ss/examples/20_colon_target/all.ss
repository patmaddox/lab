target hello:world
needs hello.c

hello:world() {
	cc -o ${outfile} ${deps}
}
