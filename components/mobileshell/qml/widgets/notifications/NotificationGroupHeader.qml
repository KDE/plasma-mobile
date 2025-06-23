/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.notificationmanager as NotificationManager

import org.kde.coreaddons 1.0 as KCoreAddons

RowLayout {
    id: notificationHeading

    property bool inLockScreen: false
    property var applicationIconSource
    property string applicationName
    property string originName

    spacing: Kirigami.Units.smallSpacing
    Layout.preferredHeight: Math.max(applicationNameLabel.implicitHeight, Kirigami.Units.iconSizes.small)

    Kirigami.Icon {
        id: applicationIconItem
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        Layout.preferredWidth: Kirigami.Units.iconSizes.small
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
        source: notificationHeading.applicationIconSource
        visible: valid
    }

    PlasmaComponents.Label {
        id: applicationNameLabel
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.fillWidth: true

        color: inLockScreen ? "white" : Kirigami.Theme.textColor

        opacity: 0.75
        elide: Text.ElideLeft
        font.bold: true
        text: notificationHeading.applicationName + (notificationHeading.originName ? " · " + notificationHeading.originName : "")
    }

    Item {
        id: spacer
        Layout.fillWidth: true
    }
}
