
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

Rectangle {
    id: background
    radius: Kirigami.Units.cornerRadius

    border.width: 1
    border.color: Kirigami.Theme.highlightColor
    border.pixelAligned: false

    color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2)
}
