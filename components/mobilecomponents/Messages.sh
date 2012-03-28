#! /usr/bin/env bash
$XGETTEXT `find . -name \*.qml` -L Java -o $podir/libmobilecomponentsplugin.pot
rm -f rc.cpp

