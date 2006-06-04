# dummy Makefile

all: build
build:
	./build.sh

incoming:
	./build.pl --download

update:
	./update.sh

.PHONY: all build update incoming
