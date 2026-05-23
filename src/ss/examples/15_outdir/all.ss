target hello
needs hello.c
out-of-tree

hello() {
	cc -o ${outfile} ${deps}
}
