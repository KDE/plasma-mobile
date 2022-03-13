/*
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.15

QtObject {
    enum ModelType {
        NotificationsModel, // used on the shell
        WatchedNotificationsModel // used on the lockscreen
    }
}
