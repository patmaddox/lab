target hello
needs hello.c : hello.h note.txt

hello() {
	cc -o ${target} ${deps}
}
