/*
 *  Copyright 2015 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

PlasmaCore.ColorScope {
    id: root
    width: 600
    height: 480
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    
    property QtObject taskSwitcher: taskSwitcherLoader.item ? taskSwitcherLoader.item : null
    Loader {
        id: taskSwitcherLoader
    }
    //FIXME: why it crashes on startup if TaskSwitcher is loaded immediately?
    Timer {
        running: true
        interval: 200
        onTriggered: taskSwitcherLoader.source = Qt.resolvedUrl("TaskSwitcher.qml")
    }

    MouseArea {
        id: mainMouseArea
        anchors.fill: parent
        property int oldMouseY: 0
        drag.filterChildren: true
        onPressed: {
            oldMouseY = mouse.y;
            taskSwitcher.offset = -taskSwitcher.height
        }
        onPositionChanged: {
            taskSwitcher.offset = taskSwitcher.offset - (mouse.y - oldMouseY);
            oldMouseY = mouse.y;
            if (taskSwitcher.visibility == Window.Hidden && taskSwitcher.offset > -taskSwitcher.height + units.gridUnit) {
                taskSwitcher.visibility = Window.FullScreen;
            }
        }
        onReleased: {
            if (taskSwitcher.visibility == Window.Hidden) {
                return;
            }
            if (taskSwitcher.offset > -taskSwitcher.height/2) {
                taskSwitcher.show();
            } else {
                taskSwitcher.hide();
            }
        }

        Rectangle {
            anchors.fill: parent
            color: root.backgroundColor

            width: 600
            height: 40

            property Item toolBox

            Button {
                anchors.left: parent.left
                height: parent.height
                width: parent.width/3
                enabled: taskSwitcher.tasksCount > 0
                iconSource: "applications-other"
                onClicked: taskSwitcher.visible ? taskSwitcher.hide() : taskSwitcher.show();
            }

            Button {
                id: showDesktopButton
                height: parent.height
                width: parent.width/3
                anchors.horizontalCenter: parent.horizontalCenter
                iconSource: "go-home"
                checkable: true
                onCheckedChanged: {print (checked)
                    plasmoid.nativeInterface.showDesktop = checked;
                }
                Connections {
                    target: plasmoid.nativeInterface
                    onShowingDesktopChanged: {
                        showDesktopButton.checked = plasmoid.nativeInterface.showDesktop;
                    }
                }
            }

            Button {
                height: parent.height
                width: parent.width/3
                anchors.right: parent.right
                iconSource: "window-close"
                enabled: plasmoid.nativeInterface.hasCloseableActiveWindow;
                onClicked: plasmoid.nativeInterface.closeActiveWindow();
            }
        }
    }
}
