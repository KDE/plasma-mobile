// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.components 3.0 as PC3
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

PC3.Label {
    id: label
    wrapMode: Text.WordWrap
    maximumLineCount: 2
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignTop
    elide: Text.ElideRight

    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.8
    font.weight: Font.Bold
}
