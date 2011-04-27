#!/bin/sh

mkdir -p theme;
mkdir -p theme/cursors;

for file in $(ls config/*.in); do
    xcursorgen $file theme/cursors/$(echo $file |cut -d. -f1)
done

cp index.theme theme/

tar -cjf plasma-mobile-cursors.tar.bz2 theme/
rm -rf theme;

