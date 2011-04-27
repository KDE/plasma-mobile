#!/bin/sh

DIR="r-conf"

cd r-conf;
for file in $(ls *.in); do
#    echo $file
    xcursorgen $file $(echo $file |cut -d. -f1)
done

