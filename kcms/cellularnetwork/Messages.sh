#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later
$XGETTEXT `find . -name \*.cpp -o -name \*.qml` -o $podir/kcm_cellular_network.pot
