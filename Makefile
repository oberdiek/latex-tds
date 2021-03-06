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
README.html: build/README.html
	perl -pe 's/\s+$$/\n/' <$< >$@
build/README.html: README.asciidoc README-docinfo.html
	asciidoc --out-file $@ $<
README.pdf: README.html
	wkhtmltopdf $< $@
#NOTOC_HTML = build/README-notoc.html
#README.pdf: README.asciidoc
#	-mkdir build
#	asciidoc --out-file $(NOTOC_HTML) \
#	    -a disable-javascript -a toc! $<
#	lowriter --invisible --convert-to odt --outdir build $(NOTOC_HTML)
#	cp build/README-notoc.odt build/README.odt
#	lowriter --invisible --convert-to pdf build/README.odt

# update:
# 	./update.sh

spell: README.asciidoc ispell.dict
	ispell -d american-huge -p ispell.dict $<
ispell.dict:
	touch $@

check: spell check-files check-links check-manifest

check-files: README.asciidoc README.html build.pl build.sh ctan_upload.pl \
             tex/* lib/* license/*
	lib/check-eolspaces.pl $+
	lib/check-ascii.pl $+

check-links: README.html
	-linkchecker \
	    --anchors \
	    --no-warnings \
	    --file-output=text/check-links.log \
	    $<
#	    --ignore-url=ftp://ftp.ams.org/ \

check-manifest: ./lib/check-manifest.pl
	$<

ziptimetree: lib/ziptimetree.pl
lib/ziptimetree.pl: $(HOME)/bin/ziptimetree
	install -m 755 $< $@

clean:
	-$(RM) README.bak README.asciidoc.bak

.PHONY: all build distrib update incoming ziptimetree spell license \
        check check-links check-files check-manifest clean readme
