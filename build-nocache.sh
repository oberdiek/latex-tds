#!/bin/sh
rm -rf build
rm -rf distrib
time ./build.pl --nocache --all 2>&1 | tee build.log
./build-last.pl
