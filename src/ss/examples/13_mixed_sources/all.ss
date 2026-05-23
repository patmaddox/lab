target bar
needs bar.c

bar() {
	cc -o ${target} ${deps}
}
