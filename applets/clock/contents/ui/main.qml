/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents


PlasmaComponents.Label {
    id: bigClock

    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight

    text: Qt.formatTime(timeSource.data.Local.DateTime, "hh:mm")
    color: PlasmaCore.ColorScope.textColor
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    font.pointSize: 40
    style: Text.Raised
    styleColor: "black"
}
