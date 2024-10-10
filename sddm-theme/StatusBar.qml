/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */


import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as Controls
import QtQml.Models

import org.kde.kirigami as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.private.systemtray as SystemTray
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.private.mobileshell as MobileShell

Item {
    id: root
    readonly property real textPixelSize: 11
    readonly property real elementSpacing: Kirigami.Units.smallSpacing * 1.5

    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
        intervalAlignment: P5Support.Types.AlignToMinute
    }

    // drop shadow for icons
    MultiEffect {
        anchors.fill: control
        source: control
        blurMax: 16
        shadowEnabled: true
        shadowVerticalOffset: 1
        shadowOpacity: 0.8
    }

    // screen top panel
    Controls.Control {
        id: control
        z: 1
        topPadding: Kirigami.Units.smallSpacing
        bottomPadding: Kirigami.Units.smallSpacing
        rightPadding: Kirigami.Units.smallSpacing * 3
        leftPadding: Kirigami.Units.smallSpacing * 3

        anchors.fill: parent

        contentItem: RowLayout {
            id: mainRow
            readonly property real rowHeight: MobileShell.Constants.topPanelHeight - Kirigami.Units.smallSpacing * 2

            Layout.fillWidth: true
            Layout.preferredHeight: rowHeight

            spacing: 0

            // clock
            MobileShell.ClockText {
                Layout.fillHeight: true
                fontPixelSize: textPixelSize
                source: timeSource
            }

            // spacing in the middle
            Item {
                Layout.fillWidth: true
            }

            // system indicators
            // using Layout.fillHeight here seems to cause polish loops, instead just define the height of the row
            RowLayout {
                id: indicators
                Layout.leftMargin: Kirigami.Units.smallSpacing // applets have different spacing needs
                Layout.maximumHeight: mainRow.rowHeight

                spacing: root.elementSpacing

                MobileShell.BatteryIndicator {
                    spacing: root.elementSpacing
                    textPixelSize: root.textPixelSize
                    implicitHeight: mainRow.rowHeight
                    Layout.preferredWidth: height
                }
            }
        }
    }
}
