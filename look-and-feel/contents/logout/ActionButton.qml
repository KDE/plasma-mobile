/*
 *   SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>
 *   SPDX-FileCopyrightText: 2022 Seshan Ravikumar <seshan10@me.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.8

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: root
    property alias text: label.text
    property alias iconSource: icon.source
    property alias containsMouse: mouseArea.containsMouse
    property alias font: label.font
    property alias labelRendering: label.renderType
    property alias circleOpacity: buttonRect.opacity
    property alias circleVisiblity: buttonRect.visible
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    signal clicked

    activeFocusOnTab: true

    property int iconSize: PlasmaCore.Units.gridUnit

    implicitWidth: PlasmaCore.Units.gridUnit * 14
    implicitHeight: iconSize + PlasmaCore.Units.smallSpacing + label.implicitHeight

    Rectangle {
        id: buttonRect
        width: root.width
        height: iconSize * 2.2
        radius: PlasmaCore.Units.smallSpacing
        color: PlasmaCore.ColorScope.backgroundColor
        opacity: mouseArea.containsPress ? 1 : 0.6
        border {
            color: Qt.rgba(255, 255, 255, 0.8)
            width: 1
        }
    }

    PlasmaCore.IconItem {
        id: icon
        anchors {
            verticalCenter: buttonRect.verticalCenter
            left: buttonRect.left
            leftMargin: PlasmaCore.Units.mediumSpacing
        }
        width: iconSize
        height: iconSize

        colorGroup: PlasmaCore.ColorScope.colorGroup
    }

    PlasmaComponents3.Label {
        id: label
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize + 1
        anchors {
            centerIn: buttonRect
        }
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? PlasmaCore.ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        font.underline: root.activeFocus
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        onClicked: root.clicked()
        anchors.fill: parent
    }

    Keys.onEnterPressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()

    Accessible.onPressAction: clicked()
    Accessible.role: Accessible.Button
    Accessible.name: label.text
}
