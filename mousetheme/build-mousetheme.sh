#!/bin/sh

mkdir -p theme;
mkdir -p theme/cursors;

cd config;
for file in $(ls *.in); do
    xcursorgen $file ../theme/cursors/$(echo $file |cut -d. -f1)
done
cd ..;

cp index.theme theme/

tar -cjf plasma-mobile-cursors.tar.bz2 theme/
# rm -rf theme;

