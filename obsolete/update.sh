#!/bin/sh
scp distrib/*.zip dbis:.public_html/tmp/latex-tds/
ssh dbis "chmod 644 .public_html/tmp/latex-tds/*-tds.zip"
scp index.html readme.txt dbis:.public_html/tmp/latex-tds/
ssh dbis "chmod 644 .public_html/tmp/latex-tds/index.html"
ssh dbis "chmod 644 .public_html/tmp/latex-tds/readme.txt"
