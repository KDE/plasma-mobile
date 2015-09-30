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
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2

FullScreenPanel {
    id: window

    visible: false
    width: Screen.width
    height: Screen.height
    property int offset: 0
    property int overShoot: units.gridUnit * 2

    color: Qt.rgba(0, 0, 0, 0.6 * Math.min(
        (Math.min(tasksView.contentY + tasksView.height, tasksView.height) / tasksView.height),
        ((tasksView.contentHeight - tasksView.contentY - tasksView.headerItem.height - tasksView.footerItem.height)/tasksView.height)))

    function show() {
        if (!visible) {
            tasksView.contentY = -tasksView.headerItem.height;
        }
        visible = true;
        scrollAnim.from = tasksView.contentY;
        scrollAnim.to = 0;
        scrollAnim.running = true;
    }
    function hide() {
        scrollAnim.from = tasksView.contentY;
        if (tasksView.contentY + tasksView.headerItem.height < tasksView.contentHeight/2) {
            scrollAnim.to = -tasksView.headerItem.height;
        } else {
            scrollAnim.to = tasksView.contentHeight - tasksView.headerItem.height;
        }
        scrollAnim.running = true;
    }

    onOffsetChanged: tasksView.contentY = offset

    SequentialAnimation {
        id: scrollAnim
        property alias to: internalAnim.to
        property alias from: internalAnim.from
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
                if (tasksView.contentY <= -tasksView.headerItem.height || tasksView.contentY >= tasksView.contentHeight - tasksView.headerItem.height) {
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
            if (!draggingVertically && contentY < -headerItem.height + window.height ||
                (contentY + footerItem.height) > (contentHeight - footerItem.height - window.height/6*5)) {
                window.hide();
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

            //hide by scrolling down
            } else if ((contentY + footerItem.height) > (contentHeight - footerItem.height - window.height/6*5)) {
                hide();
                return;
            //show
            } else if ((contentY + tasksView.height) > (contentHeight - headerItem.height - footerItem.height) &&
                (contentY + tasksView.height) < (contentHeight - headerItem.height - footerItem.height + window.height/6*5)) {
                scrollAnim.from = tasksView.contentY;
                visible = true;
                
                scrollAnim.to = contentHeight - footerItem.height - tasksView.height*2;
                scrollAnim.running = true;
                return;
            } else if (contentY < 0) {
                show();
            }
        }

        PlasmaCore.SortFilterModel {
            id: filteredWindowModel
            filterRole: "SkipsTaskbar"
            filterRegExp: "false"
            sourceModel: plasmoid.nativeInterface.windowModel
        }

        model: filteredWindowModel
        header: Item {
            width: window.width
            height: window.height
        }
        footer: Item {
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
