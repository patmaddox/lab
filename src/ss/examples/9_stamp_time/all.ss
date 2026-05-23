stamp build_timestamp

target hello
needs hello.c : build_timestamp

build_timestamp() {
	date +%Y-%m-%dT%H:%M:%S.%N > ${target}
}

hello() {
	cc -o ${target} ${deps}
}
