target hello
needs hello.c missing.h

hello() {
	cc -o ${outfile} hello.c
}
