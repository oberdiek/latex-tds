#!/bin/sh
scp distrib/*.zip dbis:.public_html/tmp/latex-tds/
ssh dbis "chmod 644 .public_html/tmp/latex-tds/*-tds.zip"
scp index.html dbis:.public_html/tmp/latex-tds/
ssh dbis "chmod 644 .public_html/tmp/latex-tds/index.html"
