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
        anchors.fill: parent
        color: PlasmaCore.ColorScope.backgroundColor
        opacity: 0.5
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelRequested()
    }

    KCoreAddons.KUser {
        id: kuser
    }

    Controls.Popup {
        visible: true
        anchors.centerIn: parent
        width: Math.min(units.gridUnit * 20, root.width * 0.8)
        height: Math.min(units.gridUnit * 25, root.height * 0.7)
        Component.onCompleted: open()

        ColumnLayout {
            id: contents
            spacing: units.largeSpacing
            anchors.fill: parent

            UserDelegate {
                Layout.fillWidth: true
                width: units.gridUnit * 7
                height: width
                nameFontSize: theme.defaultFont.pointSize + 4
                constrainText: false
                avatarPath: kuser.faceIconUrl
                iconSource: "user-identity"
                isCurrent: true
                name: kuser.fullName
            }

            ColumnLayout {
                Layout.margins: 10
                Controls.Button {
                    Layout.fillWidth: true
                    display: Controls.Button.TextUnderIcon
                    icon.name: "system-shutdown"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                    onClicked: root.haltRequested()
                }

                Controls.Button {
                    Layout.fillWidth: true
                    display: Controls.Button.TextUnderIcon
                    icon.name: "system-reboot"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                    onClicked: root.rebootRequested()
                }
            }
        }
    }
}
