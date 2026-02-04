/* Example C file for FreeBSD style(9) */
#include <stdio.h>
#include <stdlib.h>

struct point {
	int	x;
	int	y;
};

int
main(int argc, char *argv[])
{
	struct point p;
	int i;

	if (argc < 2) {
		fprintf(stderr, "Usage: %s <number>\n",
		    argv[0]);
		return (1);
	}

	for (i = 0; i < argc; i++) {
		printf("arg %d: %s\n", i, argv[i]);
	}

	p.x = 10;
	p.y = 20;

	return (0);
}
