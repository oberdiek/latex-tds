#!/bin/sh
rm -rf build
./build.pl 2>&1 | tee build.log
