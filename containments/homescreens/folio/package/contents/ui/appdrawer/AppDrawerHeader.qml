/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root
    
    signal switchToListRequested()
    signal switchToGridRequested()
    
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false
    
    // HACK: Here only to steal inputs the would normally be delivered to home
    MouseArea {
        anchors.fill: parent
    }
    
    RowLayout {
        anchors.topMargin: Kirigami.Units.smallSpacing
        anchors.leftMargin: Kirigami.Units.gridUnit
        anchors.rightMargin: Kirigami.Units.gridUnit
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing
        
        Kirigami.Heading {
            color: "white"
            level: 1
            text: i18n("Applications")
            font.weight: Font.Medium
        }
        Item { Layout.fillWidth: true }
        PlasmaComponents.ToolButton {
            icon.name: "view-list-symbolic"
            implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.1)
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.1)
            onClicked: root.switchToListRequested()
        }
        PlasmaComponents.ToolButton {
            icon.name: "view-grid-symbolic"
            implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.1)
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.1)
            onClicked: root.switchToGridRequested()
        }
    }
}
