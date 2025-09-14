// SPDX-FileCopyrightText: 2021-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.plasma.plasmoid

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

Item {
    id: root

    // The full intended height of the status panel.
    required property real statusPanelHeight

    // Whether the background should be transparent, with content using a complementary theme on top.
    required property bool transparentBackground

    // Request the panel itself to reapply settings (ex. for updating touch area).
    signal updatePanelPropertiesRequested()


    Kirigami.Theme.colorSet: transparentBackground ? Kirigami.Theme.Complementary : Kirigami.Theme.Header
    Kirigami.Theme.inherit: false

    property real offset: 0

    MobileShell.StatusBar {
        id: topPanel
        anchors.fill: parent

        showSecondRow: false
        showTime: !MobileShellState.LockscreenDBusClient.lockscreenActive // Don't show time on the lockscreen, since we already have a massive clock

        showDropShadow: false
        backgroundColor: root.transparentBackground ? "transparent" : Kirigami.Theme.backgroundColor

        transform: [
            Translate {
                y: root.offset
            }
        ]
    }

    states: [
        State {
            // Default panel state, which is shown in the UI.
            name: "default"
            PropertyChanges {
                target: root; offset: 0
            }
        },
        State {
            // Panel is forced to be visible and overlaid over content (will be automatically hidden after a duration).
            name: "visible"
            PropertyChanges {
                target: root; offset: 0
            }
        },
        State {
            // Panel is hidden and requires a gesture to be shown.
            name: "hidden"
            PropertyChanges {
                target: root; offset: -root.statusPanelHeight
            }
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            ParallelAnimation {
                PropertyAnimation {
                    properties: "offset"
                    easing.type: root.state === "hidden" ? Easing.InExpo : Easing.OutExpo
                    duration: Kirigami.Units.longDuration
                }
            }
            ScriptAction {
                script: {
                    root.updatePanelPropertiesRequested();
                }
            }
        }
    }
}
