target hello
needs hello.c : hello.h note.txt

hello() {
	cc -o ${outfile} ${deps}
}
