#! /usr/bin/env bash
$XGETTEXT `find . -name \*.qml` -L Java -o $podir/org.kde.activityswitcher.pot
rm -f rc.cpp
