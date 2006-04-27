#!/bin/sh
rm -rf build
rm -rf distrib
./build.pl 2>&1 | tee build.log
