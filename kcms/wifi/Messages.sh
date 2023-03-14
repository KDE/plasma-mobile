#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2018 Martin Kacej <m.kacej@atlas.sk>
# SPDX-License-Identifier: LGPL-2.0-or-later
$XGETTEXT `find . -name \*.cpp -o -name \*.qml` -o $podir/kcm_mobile_wifi.pot
