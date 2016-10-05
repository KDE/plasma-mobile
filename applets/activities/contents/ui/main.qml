/*
 *   Copyright 2016 Marco Martin <notmart@gmail.com>
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

import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.activities 0.1 as Activities

ColumnLayout {
    ListView {
        id: listView
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: Activities.ActivityModel {
            id: activityModel
        }
        delegate: MouseArea {
                id: delegate
                drag {
                    target: listView.count > 0  && !model.current? delegate : null
                    axis: Drag.XAxis
                }
                PlasmaComponents.Highlight {
                    visible: model.current
                    anchors.fill:parent
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
                height: label.height
                onClicked: {
                    listView.currentIndex = index;
                    activityModel.setCurrentActivity(model.id, function() {});
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
    PlasmaComponents.ToolButton {
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
                        print("AAA"+id)
                        activityModel.setCurrentActivity(id, function() {});
                    });
                }
            }
        }
    }
}
