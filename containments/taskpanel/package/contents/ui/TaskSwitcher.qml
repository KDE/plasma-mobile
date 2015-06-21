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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2

import org.kde.plasma.private.taskmanager 0.1 as TaskManager

FullScreenPanel {
    id: window

    visible: false
    width: Screen.width
    height: Screen.height
    property int offset: 0
    property int overShoot: units.gridUnit * 2

    color: Qt.rgba(0, 0, 0, 0.6 * (Math.min(tasksView.contentY + window.height, window.height) / window.height))

    function show() {
        visible = true;
        scrollAnim.to = 0;
        scrollAnim.running = true;
    }
    function hide() {
        scrollAnim.to = -tasksView.headerItem.height;
        scrollAnim.running = true;
    }

    TaskManager.Backend {
        id: backend

        highlightWindows: false

        //NoGrouping
        groupingStrategy: 0
        //AlphaSorting
        sortingStrategy: 2
    }

    SequentialAnimation {
        id: scrollAnim
        property alias to: internalAnim.to
        ScriptAction {
            script: window.visible = true;
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
                if (tasksView.contentY <= -tasksView.headerItem.height) {
                    window.visible = false;
                }
            }
        }
    }
    GridView {
        id: tasksView
        width: window.width
        height: window.height
        cellWidth: window.width/2
        cellHeight: window.height/2
        onFlickingChanged: {
            if (!draggingVertically && contentY < -headerItem.height + window.height) {
                scrollAnim.to = Math.round(contentY/window.height) * window.height
                scrollAnim.running = true;
            }
        }
        onDraggingVerticallyChanged: {
            if (draggingVertically) {
                return;
            }

            //manage separately the first page, the lockscreen
            //scrolling down
            if (verticalVelocity > 0 && contentY < -headerItem.height + window.height &&
                contentY > (-headerItem.height + window.height/6)) {
                show();
                return;

            //scrolling up
            } else if (verticalVelocity < 0 && contentY < -headerItem.height + window.height &&
                contentY < (-headerItem.height + window.height/6*5)) {
                hide();
                return;
            }

            if (contentY < 0) {
                show();
            }
        }

        model: backend.tasksModel
        header: Item {
            width: window.width
            height: window.height
        }
        delegate: Task {}
        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}
