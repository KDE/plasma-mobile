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
import QtQuick 2.0;
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

    function closeWindowList() {
        hideAnim.running = true;
    }

    onVisibleChanged: {
        if (visible) {
            showAnim.running = true;
        }
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
            cellWidth: units.gridUnit * 20
            cellHeight: units.gridUnit * 20 // (view.width / view.height)
            model: KWinScripting.ClientModel {
                id: clientModel
                exclusions: KWinScripting.ClientModel.NotAcceptingFocusExclusion |
                            KWinScripting.ClientModel.DesktopWindowsExclusion |
                            KWinScripting.ClientModel.DockWindowsExclusion |
                            KWinScripting.ClientModel.SwitchSwitcherExclusion
            }
            onMovingChanged: {
                if (contentY < -view.height/2) {
                    hideAnim.running = true
                } else if (contentY >= -view.height/2 && contentY < 0) {
                    showAnim.running = true
                }
            }
            header: Item {
                width: view.width
                height: view.height
            }
            delegate: MouseArea {
                width: view.cellWidth
                height: view.cellHeight
                PlasmaComponents.ToolButton {
                    anchors.right: parent.right
                    iconSource: "window-close"
                    flat: false
                    onClicked: model.client.closeWindow()
                    visible: model.client.closeable
                }
                KWinScripting.ThumbnailItem {
                    anchors.fill: parent
                    //parentWindow: dialog.windowId
                    client: model.client
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
