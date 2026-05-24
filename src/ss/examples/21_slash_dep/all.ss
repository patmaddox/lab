target hello
needs hello.c : inc/hello.h

hello() {
	cc -o ${outfile} ${deps}
}
