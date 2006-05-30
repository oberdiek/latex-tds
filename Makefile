# dummy Makefile

all: build
build:
	./build.sh

incoming:
	./incoming.pl

update:
	./update.sh

.PHONY: all build update incoming
