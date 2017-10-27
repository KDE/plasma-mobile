/*
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

RowLayout {
    id: delegateRoot
    property bool toggled: model.enabled
    spacing: units.smallSpacing
    implicitWidth: flow.width / 2 - units.largeSpacing / 2
    Rectangle {
        Layout.minimumWidth: units.iconSizes.medium
        Layout.minimumHeight: width
        color: toggled ? 
            Qt.rgba(PlasmaCore.ColorScope.highlightColor.r, PlasmaCore.ColorScope.highlightColor.g, PlasmaCore.ColorScope.highlightColor.b, iconMouseArea.pressed ? 0.5 : 0.3) :
            Qt.rgba(PlasmaCore.ColorScope.textColor.r, PlasmaCore.ColorScope.textColor.g, PlasmaCore.ColorScope.textColor.b, iconMouseArea.pressed ? 0.5 : 0.2)

        PlasmaCore.IconItem {
            colorGroup: PlasmaCore.ColorScope.colorGroup
            anchors {
                fill: parent
                margins: units.smallSpacing
            }
            source: model.icon
            MouseArea {
                id: iconMouseArea
                anchors.fill: parent
                onClicked: {
                    if (model.plasmoidId > -1) {
                        root.plasmoidTriggered(model.applet, model.plasmoidId);
                    } else if (delegateRoot.toggle) {
                        delegateRoot.toggle();
                    } else if (model.toggleFunction) {
                        root[model.toggleFunction]();
                    } else if (model.settingsCommand) {
                        plasmoid.nativeInterface.executeCommand(model.settingsCommand);
                    }
                }
            }
        }
    }
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Qt.rgba(PlasmaCore.ColorScope.textColor.r, PlasmaCore.ColorScope.textColor.g, PlasmaCore.ColorScope.textColor.b, labelMouseArea.pressed ? 0.5 : 0.2)
        PlasmaComponents.Label {
            anchors {
                fill: parent
                margins: units.smallSpacing
            }
            text: model.text
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            MouseArea {
                id: labelMouseArea
                anchors.fill: parent
                onClicked: {
                    if (model.plasmoidId > -1) {
                        root.plasmoidTriggered(model.applet, model.plasmoidId);
                    } else if (model.settingsCommand) {
                        plasmoid.nativeInterface.executeCommand(model.settingsCommand);
                    } else if (model.toggleFunction) {
                        root[model.toggleFunction]();
                    }
                }
            }
        }
    }
}

