#! /usr/bin/env bash
$XGETTEXT `find . -name \*.qml` -L Java -o $podir/plasma_package_org.kde.active.launcher.pot
rm -f rc.cpp
