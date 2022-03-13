/*
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
            anchors.centerIn: parent
            implicitWidth: PlasmaCore.Units.iconSizes.smallMedium
            implicitHeight: width
            source: root.icon
        }
    }
}

