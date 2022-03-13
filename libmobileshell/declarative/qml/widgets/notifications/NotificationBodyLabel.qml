/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2011 Marco Martin <notmart@gmail.com>
 * SPDX-FileCopyrightText: 2014, 2019 Kai Uwe Broulik <kde@privat.broulik.de>
 * 
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.15
import QtQuick.Window 2.2

import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmaComponents.Label {
    id: bodyText

    background: Item {}
    // Work around Qt bug where NativeRendering breaks for non-integer scale factors
    // https://bugreports.qt.io/browse/QTBUG-67007
    renderType: Screen.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering

    opacity: 0.6
    maximumLineCount: 3
    elide: Text.ElideRight
    wrapMode: Text.Wrap
    textFormat: TextEdit.RichText
}

