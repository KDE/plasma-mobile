/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.components 3.0 as PlasmaComponents

import "../../components" as Components

QuickSettingsDelegate {
    id: root

    padding: PlasmaCore.Units.smallSpacing * 2
    iconItem: icon
    
    background: Rectangle {
        radius: PlasmaCore.Units.smallSpacing
        border.color: root.enabled ? root.enabledButtonBorderColor : root.disabledButtonBorderColor
        color: {
            if (root.enabled) {
                return mouseArea.pressed ? root.enabledButtonPressedColor : root.enabledButtonColor
            } else {
                return mouseArea.pressed ? root.disabledButtonPressedColor : root.disabledButtonColor
            }
        }
    }
    
    contentItem: MouseArea {
        id: mouseArea
        onClicked: root.delegateClick()
        onPressAndHold: root.delegatePressAndHold()
        
        PlasmaCore.IconItem {
            id: icon
            anchors.top: parent.top
            anchors.left: parent.left
            implicitWidth: PlasmaCore.Units.iconSizes.small
            implicitHeight: width
            source: root.icon
        }
        
        ColumnLayout {
            id: column
            spacing: PlasmaCore.Units.smallSpacing
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            
            PlasmaComponents.Label {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: root.text
                font.pixelSize: PlasmaCore.Theme.defaultFont.pixelSize * 0.8 // TODO base height off of size of delegate
                font.weight: Font.Bold
            }
            PlasmaComponents.Label {
                Layout.fillWidth: true
                elide: Text.ElideRight
                // if no status is given, just use On/Off
                text: root.status ? root.status : (root.enabled ? i18n("On") : i18n("Off"))
                opacity: 0.6
                font.pixelSize: PlasmaCore.Theme.defaultFont.pixelSize * 0.8
            }
        }
    }
}

