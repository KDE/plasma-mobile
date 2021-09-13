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

Item {
    required property QtObject provider

    property real labelPixelSize
    
    width: strengthIcon.height + label.width
    Layout.minimumWidth: strengthIcon.height + label.width

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
        anchors.leftMargin: PlasmaCore.Units.smallSpacing
        anchors.left: strengthIcon.right
        anchors.verticalCenter: parent.verticalCenter

        text: provider.label
        color: PlasmaCore.ColorScope.textColor
        font.pixelSize: labelPixelSize
    }
}
