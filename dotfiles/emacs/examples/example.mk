# Example Makefile

PREFIX?=	/usr/local
BINDIR=		${PREFIX}/bin
MANDIR=		${PREFIX}/share/man

PROG=	example
SRCS=	main.c util.c
OBJS=	${SRCS:.c=.o}

CFLAGS+=	-Wall -Wextra
LDFLAGS+=	-L${PREFIX}/lib

.PHONY: all clean install

all: ${PROG}

${PROG}: ${OBJS}
	${CC} ${LDFLAGS} -o $@ ${OBJS}

.c.o:
	${CC} ${CFLAGS} -c $<

clean:
	rm -f ${PROG} ${OBJS}

install: ${PROG}
	install -d ${DESTDIR}${BINDIR}
	install -m 755 ${PROG} ${DESTDIR}${BINDIR}
