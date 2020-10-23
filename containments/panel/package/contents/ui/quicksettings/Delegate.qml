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
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

ColumnLayout {
    id: delegateRoot
    spacing: units.smallSpacing
    signal closeRequested
    signal panelClosed

    // Model interface
    required property string text
    required property string icon
    required property bool enabled
    required property string settingsCommand
    required property var toggleFunction

    Rectangle {
        Layout.preferredWidth: units.iconSizes.large + units.smallSpacing
        Layout.minimumHeight: width
        Layout.alignment: Qt.AlignHCenter
        radius: units.smallSpacing
        border.color: delegateRoot.enabled ?
            Qt.darker(Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.highlightColor, {}), 1.25) :
            Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.textColor, {"alpha": 0.2*255})
        color: {
            if (delegateRoot.enabled) {
                return Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.highlightColor, {"alpha": iconMouseArea.pressed ? 0.5*255 : 0.3*255});
            } else {
                if (iconMouseArea.pressed) {
                    return Qt.darker(Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.backgroundColor, {"alpha": 0.9*255}), 1.25);
                } else {
                    return Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.backgroundColor, {"alpha": 0.3*255});
                }
            }
        }

        PlasmaCore.IconItem {
            id: icon
            colorGroup: PlasmaCore.ColorScope.colorGroup
            anchors {
                fill: parent
                margins: units.smallSpacing
            }
            source: delegateRoot.icon
            MouseArea {
                id: iconMouseArea
                anchors.fill: parent
                onClicked: {
                    if (delegateRoot.toggle) {
                        delegateRoot.toggle();
                    } else if (delegateRoot.toggleFunction) {
                        root[delegateRoot.toggleFunction]();
                    } else if (delegateRoot.settingsCommand) {
                        NanoShell.StartupFeedback.open(
                            delegateRoot.icon,
                            delegateRoot.text,
                            icon.Kirigami.ScenePosition.x + icon.width/2,
                            icon.Kirigami.ScenePosition.y + icon.height/2,
                            Math.min(icon.width, icon.height))
                        plasmoid.nativeInterface.executeCommand(delegateRoot.settingsCommand);
                        root.closeRequested();
                    }
                }
                onPressAndHold: {
                    if (delegateRoot.settingsCommand) {
                        NanoShell.StartupFeedback.open(
                            delegateRoot.icon,
                            delegateRoot.text,
                            icon.Kirigami.ScenePosition.x + icon.width/2,
                            icon.Kirigami.ScenePosition.y + icon.height/2,
                            Math.min(icon.width, icon.height))
                        closeRequested();
                        plasmoid.nativeInterface.executeCommand(delegateRoot.settingsCommand);
                    } else if (delegateRoot.toggleFunction) {
                        root[delegateRoot.toggleFunction]();
                    }
                }
            }
        }
    }
    
    PlasmaComponents.Label {
        id: label

        Layout.maximumWidth: parent.width
        Layout.alignment: Qt.AlignHCenter

        text: delegateRoot.text
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
            visible: delegateRoot.settingsCommand
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
                if (delegateRoot.settingsCommand) {
                    NanoShell.StartupFeedback.open(
                        delegateRoot.icon,
                        delegateRoot.text,
                        icon.Kirigami.ScenePosition.x + icon.width/2,
                        icon.Kirigami.ScenePosition.y + icon.height/2,
                        Math.min(icon.width, icon.height))
                    plasmoid.nativeInterface.executeCommand(delegateRoot.settingsCommand);
                    closeRequested();
                } else if (delegateRoot.toggleFunction) {
                    root[delegateRoot.toggleFunction]();
                }
            }
        }
    }
}

