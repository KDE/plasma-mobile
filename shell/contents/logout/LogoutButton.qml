/*
 *   SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>
 *   SPDX-FileCopyrightText: 2022 Seshan Ravikumar <seshan10@me.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.8
import QtQuick.Layouts 1.12

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: root
    property alias text: label.text
    property alias iconSource: icon.source
    property alias containsMouse: mouseArea.containsMouse
    property alias font: label.font
    property alias labelRendering: label.renderType
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    signal clicked

    activeFocusOnTab: true

    implicitHeight: Kirigami.Units.iconSizes.huge + label.implicitHeight + Kirigami.Units.smallSpacing
    implicitWidth: Kirigami.Units.iconSizes.huge > label.implicitWidth ? Kirigami.Units.iconSizes.huge : label.implicitWidth

    Kirigami.Icon {
        id: icon
        anchors {
            horizontalCenter: root.horizontalCenter
            top: root.top
        }
        width: Kirigami.Units.iconSizes.huge
        height: Kirigami.Units.iconSizes.huge
    }

    PlasmaComponents3.Label {
        id: label
        font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
        anchors {
            horizontalCenter: root.horizontalCenter
            top: icon.bottom
            topMargin: Kirigami.Units.smallSpacing
        }
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? Kirigami.Theme.backgroundColor : "transparent" //no outline, doesn't matter
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

    Layout.alignment: Qt.AlignCenter

    Keys.onEnterPressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()

    Accessible.onPressAction: clicked()
    Accessible.role: Accessible.Button
    Accessible.name: label.text
}
