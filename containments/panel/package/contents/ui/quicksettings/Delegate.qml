/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
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
    
    required property var settingsModel
    
    signal closeRequested
    signal panelClosed

    // Model interface
    required property string text
    required property string icon
    required property bool enabled
    required property string settingsCommand
    required property var toggleFunction
    property alias labelOpacity: label.opacity
    
    property color disabledButtonColor: PlasmaCore.Theme.backgroundColor
    property color disabledPressedButtonColor: Qt.darker(disabledButtonColor, 1.1)
    property color enabledButtonColor: Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.highlightColor, {"alpha": 0.4*255})
    property color enabledPressedButtonColor: Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.highlightColor, {"alpha": 0.6*255});

    Rectangle {
        Layout.preferredWidth: PlasmaCore.Units.iconSizes.large + PlasmaCore.Units.smallSpacing
        Layout.minimumHeight: width
        Layout.alignment: Qt.AlignHCenter
        radius: PlasmaCore.Units.smallSpacing
        border.color: delegateRoot.enabled ?
            Qt.darker(Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.highlightColor, {}), 1.25) :
            Kirigami.ColorUtils.adjustColor(PlasmaCore.ColorScope.textColor, {"alpha": 0.2*255})
        color: {
            if (delegateRoot.enabled) {
                return iconMouseArea.pressed ? enabledPressedButtonColor : enabledButtonColor
            } else {
                return iconMouseArea.pressed ? disabledPressedButtonColor : disabledButtonColor
            }
        }

        Kirigami.Icon {
            id: icon
            color: PlasmaCore.Theme.textColor
            anchors.centerIn: parent
            implicitWidth: Math.round(parent.width * 0.6)
            implicitHeight: width
            source: delegateRoot.icon
        }
        
        MouseArea {
            id: iconMouseArea
            anchors.fill: parent
            onClicked: {
                if (delegateRoot.toggle) {
                    delegateRoot.toggle();
                } else if (delegateRoot.toggleFunction) {
                    settingsModel[delegateRoot.toggleFunction]();
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
                    settingsModel[delegateRoot.toggleFunction]();
                }
            }
        }
    }
}

