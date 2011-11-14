#! /usr/bin/env bash
$EXTRACTRC `find . -name \*.rc -o -name \*.ui -o -name \*.kcfg` >> rc.cpp
$XGETTEXT `find . -name \*.qml` -o $podir/plasma_applet_org.kde.active.welcome.pot
rm -f rc.cpp
