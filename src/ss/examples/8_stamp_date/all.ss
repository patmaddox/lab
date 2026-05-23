stamp build_date

target hello
needs hello.c : build_date

build_date() {
	date +%Y-%m-%d > ${outfile}
}

hello() {
	cc -o ${outfile} ${deps}
}
