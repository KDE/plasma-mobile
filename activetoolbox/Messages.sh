#! /usr/bin/env bash
$EXTRACTRC $(find . -name \*.rc -o -name \*.ui -o -name \*.kcfg) >> rc.cpp
rm -f rc.cpp
