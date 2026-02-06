.PHONY: all build test

all: build

build:
	go get
	go build -o _build/picklog -buildvcs=false

test: build
	kyua test
