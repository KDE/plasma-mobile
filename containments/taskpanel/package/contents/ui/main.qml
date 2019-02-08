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

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

PlasmaCore.ColorScope {
    id: root
    width: 600
    height: 480
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    Plasmoid.backgroundHints: plasmoid.configuration.PanelButtonsVisible ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground

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
        property int startMouseY: 0
        property bool isDragging: false
        drag.filterChildren: true
        function managePressed(mouse) {
            startMouseY = oldMouseY = mouse.y;
            taskSwitcher.offset = -taskSwitcher.height
        }
        onPressed: managePressed(mouse);
        onPositionChanged: {
            if (!isDragging && Math.abs(startMouseY - oldMouseY) < root.height) {
                oldMouseY = mouse.y;
                return;
            } else {
                isDragging = true;
            }

            taskSwitcher.offset = taskSwitcher.offset - (mouse.y - oldMouseY);
            oldMouseY = mouse.y;
            if (taskSwitcher.visibility == Window.Hidden && taskSwitcher.offset > -taskSwitcher.height + units.gridUnit && taskSwitcher.tasksCount) {
                taskSwitcher.visible = true;
            }
        }
        onReleased: {
            if (!isDragging) {
                return;
            }

            if (taskSwitcher.visibility == Window.Hidden) {
                return;
            }
            if (taskSwitcher.offset > -taskSwitcher.height/2) {
                taskSwitcher.currentTaskIndex = -1
                taskSwitcher.show();
            } else {
                taskSwitcher.hide();
                taskSwitcher.setSingleActiveWindow(taskSwitcher.currentTaskIndex);
            }
        }

        Rectangle {
            anchors.fill: parent
            color: root.backgroundColor

            width: 600
            height: 40

            visible: plasmoid.configuration.PanelButtonsVisible
            property Item toolBox

            Button {
                anchors.left: parent.left
                height: parent.height
                width: parent.width/3
                enabled: taskSwitcher.tasksCount > 0;
                iconSource: "box"
                onClicked: {
                    plasmoid.nativeInterface.showDesktop = false;
                    taskSwitcher.visible ? taskSwitcher.hide() : taskSwitcher.show();
                }
                onPressed: mainMouseArea.managePressed(mouse);
                onPositionChanged: mainMouseArea.positionChanged(mouse);
                onReleased: mainMouseArea.released(mouse);
            }

            Button {
                id: showDesktopButton
                height: parent.height
                width: parent.width/3
                anchors.horizontalCenter: parent.horizontalCenter
                iconSource: "start-here-kde"
                enabled: taskSwitcher.tasksCount > 0
                checkable: true
                onCheckedChanged: {
                    taskSwitcher.hide();
                    plasmoid.nativeInterface.showDesktop = checked;
                }
                onPressed: mainMouseArea.managePressed(mouse);
                onPositionChanged: mainMouseArea.positionChanged(mouse);
                onReleased: mainMouseArea.released(mouse);
                Connections {
                    target: root.taskSwitcher
                    onCurrentTaskIndexChanged: {
                        if (root.taskSwitcher.currentTaskIndex < 0) {
                            showDesktopButton.checked = false;
                        }
                    }
                }
            }

            Button {
                height: parent.height
                width: parent.width/3
                anchors.right: parent.right
                iconSource: "paint-none"
                //FIXME:Qt.UserRole+9 is IsWindow Qt.UserRole+15 is IsClosable. We can't reach that enum from QML
                enabled: plasmoid.nativeInterface.hasCloseableActiveWindow
                onClicked: {
                    var index = taskSwitcher.model.activeTask;
                    if (index) {
                        taskSwitcher.model.requestClose(index);
                    }
                }
                onPressed: mainMouseArea.managePressed(mouse);
                onPositionChanged: mainMouseArea.positionChanged(mouse);
                onReleased: mainMouseArea.released(mouse);
            }
        }
    }
}
