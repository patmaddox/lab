.PHONY: all run clean

all: hello run
run: hello
	./hello
clean:
	rm -f hello

hello: hello.c
	${CC} ${CFLAGS} -o ${.TARGET} ${.ALLSRC}
