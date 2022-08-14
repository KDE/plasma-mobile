/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    property MobileShell.SignalStrengthProvider provider: MobileShell.SignalStrengthProvider
    
    required property InternetIndicator internetIndicator
    
    property bool showLabel: true
    property real textPixelSize: PlasmaCore.Units.gridUnit * 0.6
    
    width: strengthIcon.width + label.width
    Layout.minimumWidth: strengthIcon.width + label.width

    PlasmaCore.IconItem {
        id: strengthIcon
        colorGroup: PlasmaCore.ColorScope.colorGroup
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height

        source: provider.icon
    }
    
    PlasmaComponents.Label {
        id: label
        visible: showLabel
        width: visible ? implicitWidth : 0
        anchors.leftMargin: PlasmaCore.Units.smallSpacing
        anchors.left: strengthIcon.right
        anchors.verticalCenter: parent.verticalCenter

        text: provider.label
        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: textPixelSize
    }
}
