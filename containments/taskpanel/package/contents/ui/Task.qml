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
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: delegate
    width: window.width/2
    height: window.height/2

    //Workaround
    property bool active: model.IsActive
    onActiveChanged: {
        //sometimes the task switcher window itself appears, screwing up the state
        if (model.IsActive) {
           // window.currentTaskIndex = index
        }
    }

    function syncDelegateGeometry() {
        let pos = pipeWireLoader.mapToItem(tasksView, 0, 0);
        if (window.visible) {
            tasksModel.requestPublishDelegateGeometry(tasksModel.index(model.index, 0), Qt.rect(pos.x, pos.y, pipeWireLoader.width, pipeWireLoader.height), pipeWireLoader);
        } else {
          //  tasksModel.requestPublishDelegateGeometry(tasksModel.index(model.index, 0), Qt.rect(pos.x, pos.y, delegate.width, delegate.height), dummyWindowTask);
        }
    }
    Connections {
        target: tasksView
        onContentYChanged: {
            syncDelegateGeometry();
        }
    }
    Connections {
        target: window
        function onVisibleChanged() {
            syncDelegateGeometry();
        }
    }

    Component.onCompleted: syncDelegateGeometry();

    Item {
        anchors {
            fill: parent
            margins: units.smallSpacing
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
                        tasksModel.requestClose(tasksModel.index(model.index, 0));
                    }
                }
            }
        }
        Rectangle {
            id: background

            width: parent.width
            height: parent.height
            radius: units.smallSpacing
            color: theme.backgroundColor
            opacity: 1 * (1-Math.abs(x)/width)
            ColumnLayout {
                anchors {
                    fill: parent
                    margins: units.smallSpacing
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.maximumHeight: units.gridUnit
                    PlasmaCore.IconItem {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        usesPlasmaTheme: false
                        source: model.decoration
                    }
                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: model.display
                        color: theme.textColor
                    }
                    PlasmaComponents.ToolButton {
                        z: 99
                        icon.name: "window-close"
                        icon.width: units.iconSizes.medium
                        icon.height: units.iconSizes.medium
                        onClicked: {
                            slideAnim.to = -background.width*2;
                            slideAnim.running = true;
                        }
                    }
                }
                Loader {
                    id: pipeWireLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: Qt.resolvedUrl("./Thumbnail.qml")
                    onStatusChanged: {
                        if (status === Loader.Error) {
                            source = Qt.resolvedUrl("./TaskIcon.qml");
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                drag {
                    target: background
                    axis: Drag.XAxis
                }
                onPressed: delegate.z = 10;
                onClicked: {
                    window.setSingleActiveWindow(model.index, delegate);
                    if (!model.IsMinimized) {
                        window.visible = false;
                    }
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

