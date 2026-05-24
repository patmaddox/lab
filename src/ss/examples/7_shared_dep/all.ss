target foo
needs shared.txt

target bar
needs shared.txt

foo() {
	cp ${deps} ${outfile}
}

bar() {
	cp ${deps} ${outfile}
}
