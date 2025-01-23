#! /usr/bin/env bash

# SPDX-FileCopyrightText: 2025 Sebastian Kŭgler <sebas@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

$XGETTEXT `find . -name \*.js -o -name \*.qml -o -name \*.cpp` -o $podir/plasma_org.kde.plasma.quicksetting.locktouchscreen.pot


