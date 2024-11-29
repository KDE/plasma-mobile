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

import org.kde.kirigami 2.20 as Kirigami
import org.kde.coreaddons 1.0 as KCoreAddons

import org.kde.plasma.private.sessions 2.0
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

Item {
    id: root

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false
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
        id: blackOverlay
        anchors.fill: parent
        color: "black"
        opacity: 0
        z: opacity > 0 ? 1 : 0
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
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
            target: buttons
            from: 0
            to: 1
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: background
            from: 0
            to: 0.6
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: closeAnim
        running: false

        property bool closeToBlack: false
        property var callback
        function execute(call) {
            callback = call;
            closeAnim.restart();
        }
        ParallelAnimation {
            OpacityAnimator {
                target: buttons
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            OpacityAnimator {
                target: background
                from: 0.6
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            OpacityAnimator {
                target: blackOverlay
                from: 0
                to: closeAnim.closeToBlack ? 1 : 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                if (closeAnim.callback) {
                    closeAnim.callback();
                }
                buttons.opacity = 1;
                background.opacity = 0.6;
            }
        }
    }

    Item {
        id: buttons
        anchors.fill: parent
        opacity: 0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Kirigami.Units.gridUnit

            ActionButton {
                iconSource: "system-reboot"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                onClicked: {
                    closeAnim.closeToBlack = true;
                    closeAnim.execute(root.rebootRequested);
                }
            }

            ActionButton {
                iconSource: "system-shutdown"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                onClicked: {
                    closeAnim.closeToBlack = true;
                    closeAnim.execute(root.haltRequested);
                }
            }

            ActionButton {
                iconSource: "system-log-out"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log Out")
                visible: ShellSettings.Settings.allowLogout
                onClicked: {
                    closeAnim.closeToBlack = true;
                    closeAnim.execute(root.logoutRequested);
                }
            }
        }

        ActionButton {
            anchors {
                bottom: parent.bottom
                bottomMargin: Kirigami.Units.gridUnit
                horizontalCenter: parent.horizontalCenter
            }
            iconSource: "dialog-cancel"
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Cancel")
            onClicked: {
                closeAnim.closeToBlack = false;
                closeAnim.execute(root.cancelRequested);
            }
        }
    }
}
