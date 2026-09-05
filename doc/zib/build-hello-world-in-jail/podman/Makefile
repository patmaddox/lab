.PHONY: all clean

all:
	./podman.sh

clean:
	podman rm -a
	podman rmi -a
	buildah rmi -a
	buildah rm -a
