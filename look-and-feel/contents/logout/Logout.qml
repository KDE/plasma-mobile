/*
 *   SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *   SPDX-FileCopyrightText: 2020 Linus Jahn <lnj@kaidan.im>
 *   SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org
 *   SPDX-FileCopyrightText: 2022 Seshan Ravikumar <seshan10@me.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.8 as Controls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcoreaddons 1.0 as KCoreAddons

import org.kde.plasma.private.sessions 2.0

PlasmaCore.ColorScope {
    id: root

    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    signal logoutRequested()
    signal haltRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal cancelRequested()
    signal lockScreenRequested()

    Controls.Action {
        onTriggered: root.cancelRequested()
        shortcut: "Escape"
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: PlasmaCore.ColorScope.backgroundColor
        opacity: 0
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            closeAnim.execute(root.cancelRequested);
        }
    }

    Component.onCompleted: openAnim.restart()
    onVisibleChanged: {
        if (visible) {
            openAnim.restart()
        }
    }

    ParallelAnimation {
        id: openAnim
        running: true
        OpacityAnimator {
            target: lay
            from: 0
            to: 1
            duration: PlasmaCore.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: background
            from: 0
            to: 0.6
            duration: PlasmaCore.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: closeAnim
        running: false

        property var callback
        function execute(call) {
            callback = call;
            closeAnim.restart();
        }
        ParallelAnimation {
            OpacityAnimator {
                target: lay
                from: 1
                to: 0
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            OpacityAnimator {
                target: background
                from: 0.6
                to: 0
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                if (closeAnim.callback) {
                    closeAnim.callback();
                }
                lay.opacity = 1;
                lay.scale = 1;
                background.opacity = 0.6;
            }
        }
    }
    ColumnLayout {
        id: lay
        anchors {
            //top: root.top
            //horizontalCenter: root.horizontalCenter
            centerIn: root
        }

        spacing: PlasmaCore.Units.gridUnit
        opacity: 0
        ActionButton {
            iconSource: "system-reboot"
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
            onClicked: {
                closeAnim.execute(root.rebootRequested);
            }
        }

        ActionButton {
            iconSource: "system-shutdown"
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
            onClicked: {
                closeAnim.execute(root.haltRequested);
            }
        }

        ActionButton {
            iconSource: "system-log-out"
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log Out")
            onClicked: {
                closeAnim.execute(root.logoutRequested);
            }
        }
    }
    ActionButton {
            anchors {
                bottom: root.bottom
                bottomMargin: PlasmaCore.Units.largeSpacing
                horizontalCenter: parent.horizontalCenter
            }
            iconSource: "dialog-cancel"
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Cancel")
            onClicked: {
                closeAnim.execute(root.cancelRequested);
            }
    }

}
