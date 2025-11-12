/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.clock
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager

import org.kde.coreaddons 1.0 as KCoreAddons

PlasmaComponents.Label {
    id: ageLabel

    property int notificationType: model.type
    property int jobState
    property QtObject jobDetails

    property var time
    property Clock clockSource

    // notification created/updated time changed
    onTimeChanged: updateAgoText()

    Connections {
        target: clockSource
        // clock time changed
        function timeChanged() {
            ageLabel.updateAgoText()
        }
    }

    Component.onCompleted: updateAgoText()

    function updateAgoText() {
        ageLabel.agoText = MobileShell.NotificationsUtils.generateNotificationHeaderAgoText(time, jobState);
    }

    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.8

    // the "n minutes ago" text, for jobs we show remaining time instead
    // updated periodically by a Timer hence this property with generate() function
    property string agoText: ""
    visible: text !== ""
    opacity: 0.6
    text: MobileShell.NotificationsUtils.generateNotificationHeaderRemainingText(notificationType, jobState, jobDetails) || agoText
}
