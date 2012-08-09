#! /usr/bin/env bash
$EXTRACTRC `find . -name \*.rc -o -name \*.ui -o -name \*.kcfg` >> rc.cpp
$XGETTEXT `find . -name \*.qml` -L Java -o $podir/plasma_applet_org.kde.active.alarms.pot
rm -f rc.cpp
