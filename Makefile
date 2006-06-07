# dummy Makefile

all: build
build:
	./build.sh

incoming:
	./build.pl --download

update:
	./update.sh

spell: readme.txt ispell.dict
	ispell -p ispell.dict $<
ispell.dict:
	touch $@

ziptimetree: lib/ziptimetree.pl
lib/ziptimetree.pl: $(HOME)/bin/ziptimetree
	install -m 755 $< $@

.PHONY: all build update incoming ziptimetree spell
