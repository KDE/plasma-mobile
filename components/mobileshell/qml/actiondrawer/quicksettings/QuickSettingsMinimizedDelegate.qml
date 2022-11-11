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
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.components 3.0 as PlasmaComponents

import "../../components" as Components

QuickSettingsDelegate {
    id: root

    iconItem: icon
    
    // scale animation on press
    zoomScale: (MobileShell.MobileShellSettings.animationsEnabled && mouseArea.pressed) ? 0.9 : 1
    
    background: Item {
        // very simple shadow for performance
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height
            
            radius: PlasmaCore.Units.smallSpacing
            color: Qt.rgba(0, 0, 0, 0.075)
        }
        
        // background
        Rectangle {
            anchors.fill: parent
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
    }
    
    MobileShell.HapticsEffectLoader {
        id: haptics
    }
    
    contentItem: MouseArea {
        id: mouseArea
        
        onPressed: haptics.buttonVibrate();
        onClicked: root.delegateClick()
        onPressAndHold: {
            haptics.buttonVibrate();
            root.delegatePressAndHold();
        }
        
        cursorShape: Qt.PointingHandCursor
        
        PlasmaCore.IconItem {
            id: icon
            anchors.centerIn: parent
            implicitWidth: PlasmaCore.Units.iconSizes.smallMedium
            implicitHeight: width
            source: root.icon
        }
    }
}

