#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
# SPDX-License-Identifier: LGPL-2.0-or-later
$XGETTEXT `find . -name \*.cpp -o -name \*.qml` -o $podir/kcm_mobile_hotspot.pot
