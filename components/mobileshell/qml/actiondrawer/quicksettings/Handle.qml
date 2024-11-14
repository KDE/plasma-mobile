/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: handle

    signal tapped()

    implicitWidth: Kirigami.Units.gridUnit * 3
    implicitHeight: 3
    radius: height
    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.5)

    TapHandler {
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        onTapped: handle.tapped()
    }
}
