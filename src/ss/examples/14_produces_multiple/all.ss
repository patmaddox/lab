target hello
needs hello.c
produces bin/hello bin/hello.txt

hello() {
	cc -o bin/hello ${deps}
	echo "built" > bin/hello.txt
}
