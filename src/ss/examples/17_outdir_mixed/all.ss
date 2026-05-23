target greeting
needs ${TMPDIR}/new-greeting
out-of-tree

target libhello.o build_libhello
needs libhello.in : greeting

target hello
needs hello.c libhello.o
out-of-tree

greeting() {
	cp ${deps} ${target}
}

build_libhello() {
	sed "s/%%GREETING%%/$(cat $(resolve_path greeting))/" libhello.in > libhello.c
	cc -c -o ${target} libhello.c
	rm libhello.c
}

hello() {
	cc -o ${target} ${deps}
}
