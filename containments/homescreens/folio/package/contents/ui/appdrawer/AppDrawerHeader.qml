/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtra

PlasmaCore.ColorScope {
    id: root
    
    signal switchToListRequested()
    signal switchToGridRequested()
    
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    
    // HACK: Here only to steal inputs the would normally be delivered to home
    MouseArea {
        anchors.fill: parent
    }
    
    RowLayout {
        anchors.topMargin: PlasmaCore.Units.smallSpacing
        anchors.leftMargin: PlasmaCore.Units.largeSpacing
        anchors.rightMargin: PlasmaCore.Units.largeSpacing
        anchors.fill: parent
        spacing: PlasmaCore.Units.smallSpacing
        
        PlasmaExtra.Heading {
            color: "white"
            level: 1
            text: i18n("Applications")
            font.weight: Font.Medium
        }
        Item { Layout.fillWidth: true }
        PlasmaComponents.ToolButton {
            icon.name: "view-list-symbolic"
            implicitWidth: Math.round(PlasmaCore.Units.gridUnit * 2.1)
            implicitHeight: Math.round(PlasmaCore.Units.gridUnit * 2.1)
            onClicked: root.switchToListRequested()
        }
        PlasmaComponents.ToolButton {
            icon.name: "view-grid-symbolic"
            implicitWidth: Math.round(PlasmaCore.Units.gridUnit * 2.1)
            implicitHeight: Math.round(PlasmaCore.Units.gridUnit * 2.1)
            onClicked: root.switchToGridRequested()
        }
    }
}
