/*
 * Copyright 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.12 as Kirigami

Control {
    id: root
    
    property bool showSeparator: false
    
    readonly property bool controlHovered: hoverHandler.hovered
    
    signal clicked()
    signal rightClicked()
    
    leftPadding: Kirigami.Units.gridUnit
    topPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.gridUnit
    
    hoverEnabled: true
    background: Rectangle {
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, mouseArea.pressed ? 0.2 : hoverHandler.hovered ? 0.07 : 0)
        
        Behavior on color {
            ColorAnimation { duration: 70 }
        }
        
        HoverHandler {
            id: hoverHandler
        }
        
        Kirigami.Separator {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: root.leftPadding
            anchors.rightMargin: root.rightPadding
            visible: root.showSeparator
            opacity: 0.5
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked();
            } else if (mouse.button === Qt.LeftButton) {
                root.clicked();
            }
        }
    }
}

