# dummy Makefile
PRJ = latex-tds

all: build
build:
	./build.sh
distrib: build
	-rm $(PRJ).zip
	(cd distrib && zip -0 ../$(PRJ).zip *.*)
	ls -l $(PRJ).zip

incoming: license/ziptimetree/lgpl.txt license/latex-tds/lppl.txt
	./build.pl --download

license: license/ziptimetree/lgpl.txt license/latex-tds/lppl.txt
license/ziptimetree/lgpl.txt: license/ziptimetree
	cd $< && wget -N http://www.gnu.org/licenses/lgpl.txt
license/latex-tds/lppl.txt: license/latex-tds
	cd $< && wget -N ftp://ftp.ctan.org/tex-archive/macros/latex/base/lppl.txt
license/ziptimetree license/latex-tds:
	mkdir -p $@

# update:
# 	./update.sh

spell: README ispell.dict
	ispell -p ispell.dict $<
ispell.dict:
	touch $@

check: spell

ziptimetree: lib/ziptimetree.pl
lib/ziptimetree.pl: $(HOME)/bin/ziptimetree
	install -m 755 $< $@

clean:
	-$(RM) README.bak

.PHONY: all build distrib update incoming ziptimetree spell license check clean
