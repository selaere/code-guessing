#!/bin/sh
# USAGE: ./cg43.sh 6 5 1N (d R r)
sed -i 's/return math.floor(x)/return Fraction(math.floor(x))/' x7/core.py
echo P1 > img
echo 640 480 >> img
cp cg43.x7 cg43.x7.tmp
echo "$* ;2" >> cg43.x7.tmp
python -m x7 cg43.x7.tmp >> img
pnmtopng img > img.png
rm img cg43.x7.tmp
