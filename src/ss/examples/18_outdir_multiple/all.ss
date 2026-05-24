target hello
needs hello.c libhello.o
out-of-tree

target libhello.o libhello
needs libhello.c
out-of-tree

libhello() {
	cc -c -o ${outfile} ${deps}
}

hello() {
	cc -o ${outfile} ${deps}
}
