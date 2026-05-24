target bar
needs bar.c

bar() {
	cc -o ${outfile} ${deps}
}
