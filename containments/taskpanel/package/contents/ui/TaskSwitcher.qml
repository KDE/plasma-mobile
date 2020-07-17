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

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

NanoShell.FullScreenOverlay {
    id: window

    visible: false
    width: Screen.width
    height: Screen.height
    property int offset: 0
    property int overShoot: units.gridUnit * 2
    property int tasksCount: window.model.count
    property int currentTaskIndex: -1
    property TaskManager.TasksModel model

    Component.onCompleted: plasmoid.nativeInterface.panel = window;

    enum MovementDirection {
        None = 0,
        Up,
        Down
    }

    onTasksCountChanged: {
        if (tasksCount == 0) {
            hide();
        }
    }
    color: Qt.rgba(0, 0, 0, 0.6 * Math.min(
        (Math.min(tasksView.contentY, tasksView.height) / tasksView.height),
        ((tasksView.contentHeight - tasksView.contentY - window.height) / tasksView.height)))

    function show() {
        if (window.model.count == 0) {
            return;
        }

        visible = true;
        scrollAnim.from = tasksView.contentY;
        scrollAnim.to = window.height;
        scrollAnim.restart();
    }
    function hide() {
        if (!window.visible) {
            return;
        }
        scrollAnim.from = tasksView.contentY;
        if (tasksView.contentY + window.height < tasksView.contentHeight/2) {
            scrollAnim.to = 0;
        } else {
            scrollAnim.to = tasksView.contentHeight - window.height;
        }
        scrollAnim.restart();
    }

    function setSingleActiveWindow(id) {
        if (id >= 0) {
            window.model.requestActivate(window.model.index(id, 0));
        }
    }

    onOffsetChanged: tasksView.contentY = offset
    onVisibleChanged: {
        if (!visible) {
            tasksView.contentY = 0;
        }
    }

    SequentialAnimation {
        id: scrollAnim
        property alias to: internalAnim.to
        property alias from: internalAnim.from
        ScriptAction {
            script: window.showFullScreen();
        }
        NumberAnimation {
            id: internalAnim
            target: tasksView
            properties: "contentY"
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        ScriptAction {
            script: {
                if (tasksView.contentY <= 0 || tasksView.contentY >= tasksView.contentHeight - window.height) {
                    window.visible = false;
                    setSingleActiveWindow(currentTaskIndex);
                }
            }
        }
    }

    Flickable {
        id: tasksView
        width: window.width
        height: window.height
        contentWidth: width
        contentHeight: mainArea.implicitHeight
        property int flickState: TaskSwitcher.MovementDirection.None

        readonly property int movementDirection: {
            if (flickState != TaskSwitcher.MovementDirection.None) {
                return flickState;
            } else if (verticalVelocity < 0) {
                return TaskSwitcher.MovementDirection.Up;
            } else if (verticalVelocity > 0)  {
                return TaskSwitcher.MovementDirection.Down;
            } else {
                return TaskSwitcher.MovementDirection.None;
            }
        }

        onFlickingVerticallyChanged: {
            if (flickingVertically) {
                flickState = verticalVelocity < 0 ? TaskSwitcher.MovementDirection.Up : TaskSwitcher.MovementDirection.Down;
            } else if (/*!draggingVertically &&*/ !flickingVertically) {
               draggingVerticallyChanged();
               flickState = TaskSwitcher.MovementDirection.None
            }
            
        }

        onDraggingVerticallyChanged: {
            if (draggingVertically) {
                return;
            }

            let beforeBeginning = contentY <  window.height;
            let afterEnd = contentY > contentHeight - window.height * 2;

            let topCloseCondition = contentY <  window.height / 10 * 9;
            let bottomClosecondition = contentY > contentHeight - window.height * 2 - window.height / 10;

            switch (movementDirection) {
            case TaskSwitcher.MovementDirection.Up: {
                if (topCloseCondition) {
                    hide();
                } else if (beforeBeginning) {
                    show();
                } else if (afterEnd) {
                    scrollAnim.from = tasksView.contentY;
                    scrollAnim.to = tasksView.contentHeight - window.height * 2;
                    scrollAnim.restart();
                }
                break;
            }
            case TaskSwitcher.MovementDirection.Down: {
                if (bottomClosecondition) {
                    hide();
                } else if (beforeBeginning) {
                    show();
                } else if (afterEnd) {
                    scrollAnim.from = tasksView.contentY;
                    scrollAnim.to = tasksView.contentHeight - window.height * 2;
                    scrollAnim.restart();
                }
                break;
            }
            case TaskSwitcher.MovementDirection.None:
            default:
                if (beforeBeginning) {
                    show();
                } else if (afterEnd) {
                    scrollAnim.from = tasksView.contentY;
                    scrollAnim.to = tasksView.contentHeight - window.height * 2;
                    scrollAnim.restart();
                }
                break;
            }
        }

        MouseArea {
            id: mainArea
            parent: tasksView.contentItem
            width: tasksView.width
            implicitHeight: window.height * 2 + Math.max(window.height, grid.implicitHeight)
            onClicked: window.hide()

            Grid {
                id: grid
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: window.height
                }
                columns: 2

                Repeater {
                    model: window.model
                    delegate: Task {}
                }

                move: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

    }

    PlasmaComponents.RoundButton {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        icon.name: "start-here-kde"
        icon.width: units.iconSizes.medium
        icon.height: units.iconSizes.medium
        onClicked: {
            currentTaskIndex = -1;
            window.hide();
            plasmoid.nativeInterface.showDesktop = true;
        }
    }
}
