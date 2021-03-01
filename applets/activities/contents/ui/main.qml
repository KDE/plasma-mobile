/*
 *   SPDX-FileCopyrightText: 2016 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.activities 0.1 as Activities

ColumnLayout {
    PlasmaComponents.ToolButton {
        id: newButton
        Layout.fillWidth: true
        text: i18n("New Activity...")
        onClicked: {
            newEdit.visible = true;
            newEdit.forceActiveFocus();
        }
        PlasmaComponents.TextField {
            id: newEdit
            visible: false
            width: parent.width
            onFocusChanged: {
                if (!focus) {
                    visible = false
                }
            }
            onAccepted: {
                if (text != "") {
                    activityModel.addActivity(text, function(id) {
                        visible = false;
                        activityModel.setCurrentActivity(id, function() {
                            plasmoid.expanded = false;
                        });
                    });
                }
            }
        }
    }
    MouseArea {
        id: rootMouseArea
        Layout.fillWidth: true
        Layout.fillHeight: true
        drag.filterChildren: true
        onClicked: newEdit.visible = false
        ListView {
            id: listView
            anchors.fill: parent
            model: Activities.ActivityModel {
                id: activityModel
            }
            delegate: MouseArea {
                    id: delegate
                    preventStealing: true
                    drag {
                        target: listView.count > 0  ? delegate : null
                        axis: Drag.XAxis
                    }
                    PlasmaComponents.Highlight {
                        visible: model.current
                        anchors.fill:parent
                    }
                    Connections {
                        target: rootMouseArea
                        onClicked: {
                            if (!delegate.contains(rootMouseArea.mapToItem(delegate, mouse.x, mouse.y))) {
                                edit.visible = false;
                            }
                        }
                    }
                    Connections {
                        target: newButton
                        onClicked: edit.visible = false;
                    }
                    SequentialAnimation {
                        id: positionAnim
                        property alias to: xAnim.to
                        XAnimator {
                            id: xAnim
                            target: delegate
                            from: delegate.x
                            duration: units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        ScriptAction {
                            script: {
                                if (delegate.x < -delegate.width/2 || delegate.x > delegate.width/2) {
                                    activityModel.removeActivity(model.id, function() {});
                                }
                            }
                        }
                    }
                    width: listView.width
                    height: Math.max(label.height, label.height)
                    onClicked: {
                        listView.currentIndex = index;
                        activityModel.startActivity(model.id, function() {
                            activityModel.setCurrentActivity(model.id, function() {
                                plasmoid.expanded = false;
                            });
                        });
                    }
                    onPressAndHold: {
                        edit.visible = true
                        edit.focus = true
                    }
                    onReleased: {
                        if (edit.visible) {
                            edit.focus = true
                            edit.forceActiveFocus()
                        }
                        if (delegate.x < -delegate.width/2) {
                            positionAnim.to = -delegate.width;
                        } else if (delegate.x > delegate.width/2) {
                            positionAnim.to = delegate.width;
                        } else {
                            positionAnim.to = 0;
                        }

                        positionAnim.running = true;
                    }
                PlasmaComponents.Label {
                    id: label
                    text: model.name
                    anchors.verticalCenter: parent.verticalCenter
                    x: units.smallSpacing
                }
                PlasmaComponents.TextField {
                    id: edit
                    visible: false
                    text: model.name
                    width: parent.width
                    onFocusChanged: {
                        if (!focus) {
                            visible = false
                        }
                    }
                    onAccepted: {
                        if (text != "") {
                            activityModel.setActivityName(model.id, text, function() {visible = false});
                        }
                    }
                }
            }
        }
    }
}
