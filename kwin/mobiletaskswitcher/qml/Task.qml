// SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kwin 3.0 as KWinComponents

Item {
    id: delegate

    required property var taskSwitcher

    required property QtObject window
    required property int index

    required property var model

    required property real previewHeight
    required property real previewWidth

    readonly property real dragOffset: -control.y

    property bool showHeader: true
    property real darken: 0

    opacity: 1 - dragOffset / taskSwitcher.height

//BEGIN functions
    function closeApp() {
        delegate.window.closeWindow();
    }

    function activateApp() {
        taskSwitcherState.wasInActiveTask = false;
        taskSwitcher.activateWindow(model.index, delegate.window);
        window.setMaximize(true, true);
    }

    function minimizeApp() {
        delegate.window.minimized = true;
    }
//END functions

    MouseArea {
        id: control
        width: parent.width
        height: parent.height
        enabled: !taskSwitcher.taskSwitcherState.currentlyBeingOpened

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

            enabled: !taskSwitcher.taskSwitcherState.currentlyBeingOpened

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
                    source: delegate.window.icon
                }

                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                    text: delegate.window.caption
                    color: "white"
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

                color: "transparent"
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

                    KWinComponents.WindowThumbnail {
                        id: thumbSource
                        wId: delegate.window.internalId
                        anchors.fill: parent

                        layer {
                            enabled: true
                            effect: ColorOverlay {
                                color: Qt.rgba(0, 0, 0, delegate.darken)
                            }
                        }
                    }

                    TapHandler {
                        id: tapHandler
                        enabled: !taskSwitcher.taskSwitcherState.currentlyBeingOpened
                        onTapped: delegate.activateApp()
                    }
                }
            }
        }
    }
}


