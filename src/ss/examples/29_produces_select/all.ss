target hello
needs hello.c
produces bin/hello bin/hello.txt

hello() {
	cc -o bin/hello ${deps}
}

target goodbye
needs goodbye.c
produces bin/goodbye

goodbye() {
	cc -o bin/goodbye ${deps}
}
