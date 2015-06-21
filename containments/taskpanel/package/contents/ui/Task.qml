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

Item {
    id: delegate
    width: window.width/2
    height: window.height/2
    Item {
        anchors {
            fill: parent
            margins: units.gridUnit
        }
        SequentialAnimation {
            id: slideAnim
            property alias to: internalSlideAnim.to
            NumberAnimation {
                id: internalSlideAnim
                target: background
                properties: "x"
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: {
                    if (background.x != 0) {
                        backend.closeByItemId(model.Id);
                    }
                }
            }
        }
        Rectangle {
            id: background
            
            width: parent.width
            height: parent.height
            radius: units.gridUnit
            opacity: 0.8
            PlasmaCore.IconItem {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                source: model.DecorationRole
            }
            PlasmaComponents.Label {
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: model.DisplayRole
            }
            MouseArea {
                anchors.fill: parent
                drag {
                    target: background
                    axis: Drag.XAxis
                }
                onPressed: delegate.z = 10;
                onClicked: {
                    window.hide();
                    backend.activateItem(model.Id, true);
                }
                onReleased: {
                    delegate.z = 0;
                    if (Math.abs(background.x) > background.width/2) {
                        slideAnim.to = background.x > 0 ? background.width*2 : -background.width*2;
                        slideAnim.running = true;
                    } else {
                        slideAnim.to = 0;
                        slideAnim.running = true;
                    }
                }
            }
        }
    }
}

