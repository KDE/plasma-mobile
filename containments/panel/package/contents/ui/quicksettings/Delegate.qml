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
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

ColumnLayout {
    id: delegateRoot
    property bool toggled: model.enabled
    spacing: units.smallSpacing
    signal closeRequested
    signal panelClosed

    Rectangle {
        Layout.preferredWidth: units.iconSizes.large + units.smallSpacing * 2
        Layout.minimumHeight: width
        Layout.alignment: Qt.AlignHCenter
        radius: units.smallSpacing
        border.color: Qt.rgba(PlasmaCore.ColorScope.textColor.r, PlasmaCore.ColorScope.textColor.g, PlasmaCore.ColorScope.textColor.b, 0.2)
        color: toggled ? 
            Qt.rgba(PlasmaCore.ColorScope.highlightColor.r, PlasmaCore.ColorScope.highlightColor.g, PlasmaCore.ColorScope.highlightColor.b, iconMouseArea.pressed ? 0.5 : 0.3) :
            Qt.rgba(PlasmaCore.ColorScope.textColor.r, PlasmaCore.ColorScope.textColor.g, PlasmaCore.ColorScope.textColor.b, iconMouseArea.pressed ? 0.5 : 0.1)

        PlasmaCore.IconItem {
            id: icon
            colorGroup: PlasmaCore.ColorScope.colorGroup
            anchors {
                fill: parent
                margins: units.smallSpacing * 2
            }
            source: model.icon
            MouseArea {
                id: iconMouseArea
                anchors.fill: parent
                onClicked: {
                    if (delegateRoot.toggle) {
                        delegateRoot.toggle();
                    } else if (model.toggleFunction) {
                        root[model.toggleFunction]();
                    } else if (model.settingsCommand) {
                        plasmoid.nativeInterface.executeCommand(model.settingsCommand);
                        root.closeRequested();
                    }
                }
            }
        }
    }
    
    PlasmaComponents.Label {
        id: label

        Layout.maximumWidth: parent.width
        Layout.alignment: Qt.AlignHCenter

        text: model.text
        bottomPadding: units.smallSpacing * 2
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: theme.defaultFont.pixelSize * 0.8
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter

        PlasmaCore.SvgItem {
            anchors {
                left: parent.right
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -units.smallSpacing
            }
            visible: model.settingsCommand
            width: units.iconSizes.small/2
            height: width
            elementId: "down-arrow"
            svg: PlasmaCore.Svg {
                imagePath: "widgets/arrows"
            }
        }
        MouseArea {
            id: labelMouseArea
            anchors.fill: parent
            onClicked: {
                if (model.settingsCommand) {
                    //plasmoid.nativeInterface.executeCommand(model.settingsCommand);
                    closeRequested();
                } else if (model.toggleFunction) {
                    root[model.toggleFunction]();
                }
            }
        }
    }
}

