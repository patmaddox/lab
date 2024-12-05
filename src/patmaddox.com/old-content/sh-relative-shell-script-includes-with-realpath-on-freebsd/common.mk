all: root subdir

root:
	./bin/hello.sh

subdir:
	cd bin && ./hello.sh
