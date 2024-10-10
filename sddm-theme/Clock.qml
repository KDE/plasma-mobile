/*
 * SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 * SPDX-FileCopyrightText: 2020-2024 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell

Item {
    id: root
    implicitHeight: clockColumn.implicitHeight
    implicitWidth: clockColumn.implicitWidth

    property int layoutAlignment

    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000
        intervalAlignment: P5Support.Types.AlignToMinute
    }

    ColumnLayout {
        id: clockColumn
        spacing: 0

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        PC3.Label {
            text: {
                let timeText = Qt.formatTime(timeSource.data["Local"]["DateTime"], MobileShell.ShellUtil.isSystem24HourFormat ? "h:mm" : "h:mm ap");

                // Remove am/pm in 12-hour time to avoid excessive length
                if (!MobileShell.ShellUtil.isSystem24HourFormat) {
                    timeText = timeText.substring(0, timeText.length - 3);
                }
                return timeText;
            }

            color: "white"
            opacity: 0.9

            renderType: Text.NativeRendering

            Layout.alignment: root.layoutAlignment
            font.weight: Font.Medium
            font.pointSize: 64

            layer.enabled: true
            layer.effect: MobileShell.TextDropShadow {
                blurMax: 16
            }
        }
        PC3.Label {
            text: Qt.formatDate(timeSource.data["Local"]["DateTime"], "dddd, MMMM d")
            color: "white"
            opacity: 0.9

            Layout.alignment: root.layoutAlignment
            font.weight: Font.Bold
            font.pointSize: 12

            layer.enabled: true
            layer.effect: MobileShell.TextDropShadow {
                blurMax: 16
            }
        }
    }
}
