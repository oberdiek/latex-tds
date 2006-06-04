# dummy Makefile

all: build
build:
	./build.sh

incoming:
	./build.pl --download

update:
	./update.sh

ziptimetree: lib/ziptimetree
lib/ziptimetree: $(HOME)/bin/ziptimetree
	install -m 755 $< $@

.PHONY: all build update incoming ziptimetree
