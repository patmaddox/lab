target libhello.o build_lib
needs src=libhello.c

target hello
needs src=hello.c lib=libhello.o

build_lib() {
	cc -c -o ${outfile} ${src}
}

hello() {
	cc -o ${outfile} ${src} ${lib}
}
