/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.2 as QQC2
import org.kde.plasma.phone.taskpanel 1.0
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: delegate
    width: window.width/2
    height: window.height/2

    //Workaround
    required property var model
    property bool active: model.IsActive
    readonly property point taskScreenPoint: Qt.point(model.ScreenGeometry.x, model.ScreenGeometry.y)
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
            color: PlasmaCore.Theme.backgroundColor
            opacity: 1 * (1-Math.abs(x)/width)

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

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: units.smallSpacing
                    }
                    
                    RowLayout {
                        z: 99
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
                            text: model.AppName
                            color: PlasmaCore.Theme.textColor
                        }
                        Repeater {
                            id: rep
                            model: plasmoid.nativeInterface.outputs
                            delegate: PlasmaComponents.ToolButton {
                                text: model.modelName
                                visible: model.position !== delegate.taskScreenPoint
                                display: rep.count < 3 ? QQC2.Button.IconOnly : QQC2.Button.TextBesideIcon
                                icon.name: "tv" //TODO provide a more adequate icon

                                onClicked: {
                                    plasmoid.nativeInterface.sendWindowToOutput(delegate.model.WinIdList[0], model.output)
                                }
                            }
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
            }
        }
    }
}

