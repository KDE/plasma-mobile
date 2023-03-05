#! /usr/bin/env bash

# SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

$EXTRACTRC `find . -name \*.rc -o -name \*.ui -o -name \*.kcfg` >> rc.cpp
$XGETTEXT `find . -name \*.js -o -name \*.qml -o -name \*.cpp` -o $podir/plasma_applet_org.kde.plasma.mobile.taskpanel.pot
rm -f rc.cpp
