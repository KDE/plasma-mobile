/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.notificationmanager 1.0 as NotificationManager

FullContainer {
    id: fullContainer

    shouldBeVisible: applet && historyModel.count > 0
    visible: shouldBeVisible

    NotificationManager.Notifications {
        id: historyModel
        showExpired: true
        showDismissed: true
    }
}
