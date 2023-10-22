// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    RowLayout {
        anchors.topMargin: Kirigami.Units.smallSpacing
        anchors.leftMargin: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
        anchors.rightMargin: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        QQC2.Label {
            color: "white"
            text: i18n("Applications")
            font.weight: Font.Bold
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
        }
    }
}
