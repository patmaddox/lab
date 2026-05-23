stamp build_timestamp

target hello
needs hello.c : build_timestamp

build_timestamp() {
	date +%Y-%m-%dT%H:%M:%S.%N > ${outfile}
}

hello() {
	cc -o ${outfile} ${deps}
}
