# dummy Makefile

all: build
build:
	./build.sh

incoming: license/ziptimetree/lgpl.txt license/latex-tds/lppl.txt
	./build.pl --download

license: license/ziptimetree/lgpl.txt license/latex-tds/lppl.txt
license/ziptimetree/lgpl.txt: license/ziptimetree
	cd $< && wget -N http://www.gnu.org/licenses/lgpl.txt
license/latex-tds/lppl.txt: license/latex-tds
	cd $< && wget -N ftp://ftp.ctan.org/tex-archive/macros/latex/base/lppl.txt
license/ziptimetree license/latex-tds:
	mkdir -p $@

update:
	./update.sh

spell: readme.txt ispell.dict
	ispell -p ispell.dict $<
ispell.dict:
	touch $@

ziptimetree: lib/ziptimetree.pl
lib/ziptimetree.pl: $(HOME)/bin/ziptimetree
	install -m 755 $< $@

.PHONY: all build update incoming ziptimetree spell license
