#! /usr/bin/env bash
$EXTRACTRC $(find . -name \*.rc -o -name \*.ui -o -name \*.kcfg) >> rc.cpp
$XGETTEXT $(find . -name \*.qml) -L Java -o $podir/plasma_applet_org.kde.appletstrip.pot
rm -f rc.cpp
