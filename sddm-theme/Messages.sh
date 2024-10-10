#! /usr/bin/env bash
# SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later
$XGETTEXT `find . -name \*.qml` -L Java -o $podir/plasma-mobile-sddm-theme.pot

