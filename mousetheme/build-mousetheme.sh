#!/bin/sh

mkdir -p theme;

cd config;
for file in $(ls *.in); do
    xcursorgen $file ../theme/$(echo $file |cut -d. -f1)
done

