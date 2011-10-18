#! /usr/bin/env bash
$XGETTEXT `find . -name \*.qml` -L Java -o $podir/org.kde.active.activityscreen.pot
rm -f rc.cpp
