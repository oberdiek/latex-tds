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

# README

readme: README.html README.pdf
README.html: README.asciidoc
	asciidoc $<
NOTOC_HTML = build/README-notoc.html
README.pdf: README.asciidoc
	-mkdir build
	asciidoc --out-file $(NOTOC_HTML) \
	    -a disable-javascript -a toc! $<
	lowriter --invisible --convert-to odt --outdir build $(NOTOC_HTML)
	cp build/README-notoc.odt build/README.odt
	lowriter --invisible --convert-to pdf build/README.odt

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

.PHONY: all build distrib update incoming ziptimetree spell license \
        check clean readme
