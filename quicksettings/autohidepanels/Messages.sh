#! /usr/bin/env bash

# SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
# SPDX-License-Identifier: GPL-2.0-or-later

$XGETTEXT `find . -name \*.js -o -name \*.qml -o -name \*.cpp` -o $podir/plasma_org.kde.plasma.quicksetting.autohidepanels.pot
