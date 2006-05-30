#!/bin/sh
rm -rf build
rm -rf distrib
time ./build.pl 2>&1 | tee build.log
./build-last.pl
