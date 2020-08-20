/***************************************************************************
 *   Copyright (C) 2014 by Aleix Pol Gonzalez <aleixpol@blue-systems.com>  *
 *   Copyright (C) 2020 by Linus Jahn <lnj@kaidan.im>                      *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.8 as Controls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcoreaddons 1.0 as KCoreAddons

import "../components"

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
            closeAnim.restart();
            root.cancelRequested();
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
        ScaleAnimator {
            target: lay
            from: 10
            to: 1
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: lay
            from: 0
            to: 1
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: background
            from: 0
            to: 0.5
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    ParallelAnimation {
        id: closeAnim
        ScaleAnimator {
            target: lay
            from: 1
            to: 10
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: lay
            from: 1
            to: 0
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: background
            from: 0.5
            to: 0
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    GridLayout {
        id: lay
        anchors.centerIn: parent
        columns: 2
        rowSpacing: units.gridUnit * 2
        columnSpacing: units.gridUnit * 2
        scale: 2
        opacity: 0
        ActionButton {
            iconSource: "system-reboot"
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
            onClicked: {
                closeAnim.restart();
                root.rebootRequested();
            }
        }

        ActionButton {
            iconSource: "system-shutdown"
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
            onClicked: {
                closeAnim.restart();
                root.haltRequested();
            }
        }

        ActionButton {
            //Remove this when we have more buttons
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignCenter
            iconSource: "dialog-cancel"
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Cancel")
            onClicked: {
                closeAnim.restart();
                root.cancelRequested();
            }
        }
    }
}
