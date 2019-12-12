/********************************************************************
 KWin - the KDE window manager
 This file is part of the KDE project.

Copyright (C) 2012, 2013 Martin Gräßlin <mgraesslin@kde.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/
import QtQuick 2.12;
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0;
import org.kde.plasma.core 2.0 as PlasmaCore;
import org.kde.plasma.components 2.0 as PlasmaComponents;
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons;
import org.kde.kwin 2.0 as KWinScripting;

PlasmaCore.Dialog {
    id: dialog
    location: PlasmaCore.Types.Floating
    visible: false
    flags: Qt.X11BypassWindowManagerHint
    backgroundHints: PlasmaCore.Dialog.NoBackground

    property alias view: view

    function open() {
        dialog.visible = true;
        showAnim.restart();
    }
    function close() {
        hideAnim.restart();
    }

    mainItem: Rectangle {
        width: workspace.virtualScreenSize.width
        height: workspace.virtualScreenSize.height
        color: Qt.rgba(0, 0, 0, 0.5)

        SequentialAnimation {
            id: hideAnim
            NumberAnimation {
                target: view
                properties: "contentY"
                to: -view.height
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: dialog.visible = false;
            }
        }
        NumberAnimation {
            id: showAnim
            target: view
            properties: "contentY"
            to: 0
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        GridView {
            id: view
            anchors.fill: parent
            cacheBuffer: 9999
            
            cellWidth: width / Math.floor(width / (units.gridUnit * 10))
            cellHeight: cellWidth / (workspace.virtualScreenSize.width / workspace.virtualScreenSize.height) + units.gridUnit * 3
            model: KWinScripting.ClientModel {
                id: clientModel
                exclusions: KWinScripting.ClientModel.NotAcceptingFocusExclusion |
                            KWinScripting.ClientModel.DesktopWindowsExclusion |
                            KWinScripting.ClientModel.DockWindowsExclusion |
                            KWinScripting.ClientModel.SwitchSwitcherExclusion
            }
            MouseArea {
                parent: view.contentItem
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: Math.max(parent.height, view.height)
                onClicked: dialog.close()
            } 
            onMovingChanged: {
                if (moving) {
                    return;
                }
                if (contentY < -view.height/2) {
                    hideAnim.running = true
                } else if (contentY >= -view.height/2 && contentY < 0) {
                    showAnim.running = true
                }
            }
            topMargin: height
            bottomMargin: height
            delegate: MouseArea {
                width: view.cellWidth
                height: view.cellHeight
                drag.target: decoration
                drag.axis: Drag.XAxis

                onReleased: {
                    if (decoration.x > decoration.width / 2) {
                        windowCloseAnim.to = decoration.width
                        windowCloseAnim.restart()
                    } else if (decoration.x < -decoration.width / 2) {
                        windowCloseAnim.to = -decoration.width
                        windowCloseAnim.restart()
                    } else {
                        resetAnim.restart();
                    }
                }
                NumberAnimation {
                    id: resetAnim
                    target: decoration
                    property: "x"
                    from: decoration.x
                    to: 0
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
                SequentialAnimation {
                    id: windowCloseAnim
                    property alias to: internalAnim.to
                    NumberAnimation {
                        id: internalAnim
                        property: "x"
                        target: decoration
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    ScriptAction {
                        script: {
                            model.client.closeWindow()
                            decoration.x = 0;
                        }
                    }
                }
                Rectangle {
                    id: decoration
                    opacity: 1 - Math.abs(x / width)
                    width: parent.width - units.smallSpacing*2
                    height: parent.height - units.smallSpacing*2
                    radius: 3
                    color: theme.backgroundColor

                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: units.smallSpacing
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: model.client.caption
                            }
                            PlasmaComponents.ToolButton {
                                iconSource: "window-close"
                                onClicked: model.client.closeWindow()
                                visible: model.client.closeable
                            }
                        }
                        KWinScripting.ThumbnailItem {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            //parentWindow: dialog.windowId
                            opacity: decoration.opacity
                            client: model.client
                        }
                    }

                }
                onClicked: {
                    workspace.activeClient = model.client
                    hideAnim.running = true
                }
            }
        }
    }

    Component.onCompleted: {
        KWin.registerWindow(dialog);
    }
}
