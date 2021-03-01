/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

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
    color: "transparent"
    // More controllable than the color property
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        opacity: Math.min(
            (Math.min(tasksView.contentY, tasksView.height) / tasksView.height),
            ((tasksView.contentHeight - tasksView.contentY - window.height) / tasksView.height))
    }

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

        if (tasksView.contentY + window.height <= tasksView.contentHeight - tasksView.contentY) {
            scrollAnim.to = 0;
        } else {
            scrollAnim.to = tasksView.contentHeight - window.height;
        }
        scrollAnim.restart();
    }

    function setSingleActiveWindow(id, delegate) {
        if (id < 0) {
            return;
        }
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = window.model.index(i, 0)
            if (i == id) {
                window.model.requestActivate(idx);
            } else if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                tasksModel.requestToggleMinimized(idx);
            }
        }
        activateAnim.delegate = delegate;
        activateAnim.restart();
    }

    onOffsetChanged: tasksView.contentY = offset + grid.y
    onVisibleChanged: {
        if (!visible) {
            tasksView.contentY = 0;
            moveTransition.enabled = false;
            scrollAnim.running = false;
            activateAnim.running = false;
            window.contentItem.opacity = 1;
            if (activateAnim.delegate) {
                activateAnim.delegate.z = 0;
                activateAnim.delegate.scale = 1;
            }
        }
        MobileShell.HomeScreenControls.taskSwitcherVisible = visible;
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
                } else {
                    moveTransition.enabled = true;
                }
            }
        }
    }
    
    SequentialAnimation {
        id: activateAnim
        property Item delegate
        ScriptAction {
            script: {
                activateAnim.delegate.z = 2;
                let pos = tasksView.mapFromItem(activateAnim.delegate, 0, 0);
                if (pos.x < tasksView.width / 2 && pos.y < tasksView.height / 2) {
                    activateAnim.delegate.transformOrigin = Item.TopLeft;
                } else if (pos.x < tasksView.width / 2 && pos.y >= tasksView.height / 2) {
                    activateAnim.delegate.transformOrigin = Item.BottomLeft;
                } else if (pos.x >= tasksView.width / 2 && pos.y < tasksView.height / 2) {
                    activateAnim.delegate.transformOrigin = Item.TopRight;
                } else {
                    activateAnim.delegate.transformOrigin = Item.BottomRight;
                }
            }
        }
        ParallelAnimation {
            OpacityAnimator {
                target: window.contentItem
                from: 1
                to: 0
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
            ScaleAnimator {
                target: activateAnim.delegate
                from: 1
                to: 2
                // To try tosync up with kwin animation
                duration: units.longDuration * 0.85
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                window.visible = false;
            }
        }
    }

    Flickable {
        id: tasksView
        width: window.width
        height: window.height
        contentWidth: width
        contentHeight: mainArea.implicitHeight
       // topMargin: flickingVertically ? -height : 0
       // bottomMargin: flickingVertically ? -height : 0
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
               flickState = TaskSwitcher.MovementDirection.None
            }
            Qt.callLater(function() {
                tasksView.topMargin = flickingVertically && !scrollAnim.running ? -tasksView.height : 0;
                tasksView.bottomMargin = tasksView.topMargin;
            });
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
                }
                columns: 2
                y: parent.height - height - window.height

                Behavior on y {
                    NumberAnimation {
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                Repeater {
                    model: window.model
                    delegate: Task {}
                }

                move: Transition {
                    id: moveTransition
                    enabled: false
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
            //plasmoid.nativeInterface.showDesktop = true;

            root.minimizeAll();
        }
    }
}
