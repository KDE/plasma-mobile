/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell

Item {
    property InternetIndicator internetIndicator

    // check if the internet indicator icon is a mobile data related one
    readonly property bool isInternetIndicatorMobileData: internetIndicator && internetIndicator.icon && internetIndicator.icon.startsWith('network-mobile-')

    property bool showLabel: true
    property real textPixelSize: Kirigami.Units.gridUnit * 0.6

    width: strengthIcon.width + label.width
    Layout.minimumWidth: strengthIcon.width + label.width

    Kirigami.Icon {
        id: strengthIcon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height

        source: MobileShell.SignalStrengthInfo.icon

        // don't show mobile indicator icon if the networkmanager one is already showing
        visible: (!isInternetIndicatorMobileData || wirelessStatus.hotspotSSID.length !== 0) && MobileShell.SignalStrengthInfo.showIndicator
    }

    PlasmaComponents.Label {
        id: label
        visible: showLabel
        width: visible ? implicitWidth : 0
        anchors.leftMargin: Kirigami.Units.smallSpacing
        anchors.left: strengthIcon.right
        anchors.verticalCenter: parent.verticalCenter

        text: MobileShell.SignalStrengthInfo.label
        color: Kirigami.Theme.textColor
        font.pixelSize: textPixelSize
    }
}
