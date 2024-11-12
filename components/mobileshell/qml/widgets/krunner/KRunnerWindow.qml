// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.layershell 1.0 as LayerShell
import org.kde.kirigami 2.19 as Kirigami

Window {
    id: root
    visible: false
    flags: Qt.FramelessWindowHint

    onActiveChanged: {
        if (!active) {
            root.close();
        }
    }

    property real fadeFactor: 0
    Behavior on fadeFactor {
        NumberAnimation { duration: Kirigami.Units.shortDuration }
    }
    onFadeFactorChanged: {
        if (fadeFactor === 0) {
            root.visible = false;
        }
    }

    onVisibleChanged: {
        if (visible) {
            screen.clearField();
            root.raise();
            triggerVkbdTimer.restart();
            fadeFactor = 1;
        }
    }

    onClosing: (close) => {
        if (fadeFactor !== 0) {
            close.accepted = false;
            fadeFactor = 0;
        }
    }

    color: Qt.rgba(0, 0, 0, 0.8 * fadeFactor)

    // HACK: kwin seems to sometimes not show the keyboard immediately on window open
    Timer {
        id: triggerVkbdTimer
        repeat: false
        interval: 500
        onTriggered: screen.requestFocus();
    }

    MobileShell.KRunnerScreen {
        id: screen
        anchors.fill: parent
        opacity: root.fadeFactor

        onRequestedClose: {
            root.fadeFactor = 0;
        }
    }
}