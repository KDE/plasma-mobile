/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.2 as QQC2

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: delegate

    required property var taskSwitcher
    
    required property var model
    required property var displaysModel

    required property real previewHeight
    required property real previewWidth
    
    readonly property point taskScreenPoint: (model && model.ScreenGeometry) ? Qt.point(model.ScreenGeometry.x, model.ScreenGeometry.y) : Qt.point(0, 0)
    readonly property real dragOffset: -control.y
    
    property bool showHeader: true
    property real darken: 0
    
    opacity: 1 - dragOffset / taskSwitcher.height
    
//BEGIN functions
    function syncDelegateGeometry() {
        let pos = pipeWireLoader.mapToItem(delegate, 0, 0);
        if (taskSwitcher.visible) {
            tasksModel.requestPublishDelegateGeometry(tasksModel.index(model.index, 0), Qt.rect(pos.x, pos.y, pipeWireLoader.width, pipeWireLoader.height), pipeWireLoader);
        }
    }
    
    function closeApp() {
        tasksModel.requestClose(tasksModel.index(model.index, 0));
    }
    
    function activateApp() {
        taskSwitcher.activateWindow(model.index);
    }
//END functions
    
    Component.onCompleted: syncDelegateGeometry();
    
    Connections {
        target: taskSwitcher
        function onVisibleChanged() {
            syncDelegateGeometry();
        }
    }
    
    MouseArea {
        id: control
        width: parent.width
        height: parent.height
        
        // set cursor shape here, since taphandler seems to not be able to do it
        cursorShape: Qt.PointingHandCursor
        
        property bool movingUp: false
        property real oldY: y
        onYChanged: {
            movingUp = y < oldY;
            oldY = y;
        }
        
        // drag up gesture
        DragHandler {
            id: dragHandler
            target: parent
            
            yAxis.enabled: true
            xAxis.enabled: false
            yAxis.maximum: 0
            
            // y > 0 - dragging down (opening the app)
            // y < 0 - dragging up (dismissing the app)
            onActiveChanged: {
                yAnimator.stop();
                
                if (control.movingUp && parent.y < -PlasmaCore.Units.gridUnit * 2) {
                    yAnimator.to = -root.height;
                } else {
                    yAnimator.to = 0;
                }
                yAnimator.start();
            }
        }
        
        // if the app doesn't close within a certain time, drag it back
        Timer {
            id: uncloseTimer
            interval: 3000
            onTriggered: {
                yAnimator.to = 0;
                yAnimator.restart();
            }
        }
        
        NumberAnimation on y {
            id: yAnimator
            running: !dragHandler.active
            duration: PlasmaCore.Units.longDuration
            easing.type: Easing.InOutQuad
            to: 0
            onFinished: {
                if (to != 0) { // close app
                    delegate.closeApp();
                    uncloseTimer.start();
                }
            }
        }

        // application
        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: 0
            
            // header
            RowLayout {
                id: appHeader
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: column.height - appView.height
                spacing: PlasmaCore.Units.smallSpacing * 2
                opacity: delegate.showHeader ? 1 : 0
                
                Behavior on opacity {
                    NumberAnimation { duration: PlasmaCore.Units.shortDuration }
                }
                
                PlasmaCore.IconItem {
                    Layout.preferredHeight: PlasmaCore.Units.iconSizes.smallMedium
                    Layout.preferredWidth: PlasmaCore.Units.iconSizes.smallMedium
                    Layout.alignment: Qt.AlignVCenter
                    usesPlasmaTheme: false
                    source: model.decoration
                }
                
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                    text: model.AppName
                    color: "white"
                }
                
                Repeater {
                    id: rep
                    model: displaysModel
                    delegate: PlasmaComponents.ToolButton {
                        Layout.alignment: Qt.AlignVCenter
                        text: model.modelName
                        visible: model.position !== delegate.taskScreenPoint
                        display: rep.count < 3 ? QQC2.Button.IconOnly : QQC2.Button.TextBesideIcon
                        icon.name: "tv" //TODO provide a more adequate icon

                        onClicked: {
                            displaysModel.sendWindowToOutput(delegate.model.WinIdList[0], model.output)
                        }
                    }
                }
                
                PlasmaComponents.ToolButton {
                    Layout.alignment: Qt.AlignVCenter
                    z: 99
                    icon.name: "window-close"
                    icon.width: PlasmaCore.Units.iconSizes.smallMedium
                    icon.height: PlasmaCore.Units.iconSizes.smallMedium
                    onClicked: delegate.closeApp()
                }
            }
            
            // app preview
            Rectangle {
                id: appView
                Layout.preferredWidth: delegate.previewWidth
                Layout.preferredHeight: delegate.previewHeight
                Layout.maximumWidth: delegate.previewWidth
                Layout.maximumHeight: delegate.previewHeight
                
                color: PlasmaCore.Theme.backgroundColor
                clip: true
                
                // scale animation on press
                property real zoomScale: tapHandler.pressed ? 0.9 : 1
                Behavior on zoomScale {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutExpo
                    }
                }
                
                transform: Scale { 
                    origin.x: appView.width / 2; 
                    origin.y: appView.height / 2; 
                    xScale: appView.zoomScale
                    yScale: appView.zoomScale
                }
                
                Item {
                    id: item
                    anchors.fill: parent
                    
                    // app icon (behind window preview in-case it doesn't load)
                    TaskIcon {
                        // decrease the opacity faster
                        opacity: delegate.opacity
                        anchors.centerIn: parent
                    }

                    // attempt to load window preview
                    Loader {
                        id: pipeWireLoader
                        anchors.fill: parent
                        source: Qt.resolvedUrl("./Thumbnail.qml")
                    }
                    
                    // darken effect
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: delegate.darken
                    }
                    
                    TapHandler {
                        id: tapHandler
                        onTapped: delegate.activateApp()
                    }
                }
            }
        }
    }
}

