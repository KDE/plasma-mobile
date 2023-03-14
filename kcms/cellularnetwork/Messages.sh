#!/usr/bin/env bash
$XGETTEXT `find . -name \*.cpp -o -name \*.qml` -o $podir/kcm_cellular_network.pot
