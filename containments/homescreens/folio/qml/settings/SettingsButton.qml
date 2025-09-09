// SPDX-FileCopyrightText: 2025 Florian Richer <florian.richer@protonmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

PC3.ToolButton {
    id: root
    opacity: 0.9
    implicitHeight: Kirigami.Units.gridUnit * 4
    implicitWidth: Kirigami.Units.gridUnit * 5

    property string iconName
    property string textLabel

    contentItem: ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        uniformCellSizes: true

        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            Layout.fillHeight: true
            source: iconName
        }

        QQC2.Label {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            text: textLabel
            font.bold: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            wrapMode: Text.WordWrap
        }
    }
}
