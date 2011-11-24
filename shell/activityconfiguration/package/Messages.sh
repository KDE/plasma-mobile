#! /usr/bin/env bash
$XGETTEXT `find . -name \*.qml` -L Java -o $podir/plasma_package_org.kde.active.activityconfiguration.pot
rm -f rc.cpp
