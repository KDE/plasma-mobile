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

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.notificationmanager 1.0 as NotificationManager

import org.kde.kcoreaddons 1.0 as KCoreAddons

import "util.js" as Util

RowLayout {
    id: notificationHeading
    property int notificationType

    property var applicationIconSource
    property string applicationName
    property string originName

    property var time
    property PlasmaCore.DataSource timeSource

    property int jobState
    property QtObject jobDetails

    property real timeout: 5000
    property real remainingTime: 0

    spacing: PlasmaCore.Units.smallSpacing
    Layout.preferredHeight: Math.max(applicationNameLabel.implicitHeight, PlasmaCore.Units.iconSizes.small)

    PlasmaCore.IconItem {
        id: applicationIconItem
        Layout.topMargin: PlasmaCore.Units.smallSpacing
        Layout.bottomMargin: PlasmaCore.Units.smallSpacing
        Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
        Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
        source: notificationHeading.applicationIconSource
        usesPlasmaTheme: false
        visible: valid
    }

    PlasmaComponents.Label {
        id: applicationNameLabel
        Layout.leftMargin: PlasmaCore.Units.smallSpacing
        Layout.fillWidth: true
        opacity: 0.8
        textFormat: Text.PlainText
        elide: Text.ElideLeft
        text: notificationHeading.applicationName + (notificationHeading.originName ? " · " + notificationHeading.originName : "")
    }

    Item {
        id: spacer
        Layout.fillWidth: true
    }
}
