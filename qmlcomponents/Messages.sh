#! /usr/bin/env bash
$XGETTEXT `find . -name \*.qml` -L Java -o $podir/libsatellitecomponentsplugin.pot
rm -f rc.cpp

