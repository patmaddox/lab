target foo
needs foo.c
produces foo.txt bar.txt

target bar
needs bar.txt
produces out.txt

foo() {
	echo "foo ${deps}" > foo.txt
	echo "bar" > bar.txt
}

bar() {
	cp bar.txt out.txt
}
