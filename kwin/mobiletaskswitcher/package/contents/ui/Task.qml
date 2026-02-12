// SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kwin 3.0 as KWinComponents
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

Item {
    id: delegate

    required property var taskSwitcher
    property var taskSwitcherHelpers: taskSwitcher.taskSwitcherHelpers

    required property QtObject window

    required property var model

    required property real previewHeight
    required property real previewWidth

    readonly property real dragOffset: -control.y

    readonly property int currentIndex: model.index

    // whether this task is being interacted with
    readonly property bool interactingActive: control.pressed && control.passedDragThreshold

    // whether to show the text header
    property bool showHeader: true

    // the amount to darken the task preview by
    property real darken: 0

    opacity: 1 - dragOffset / taskSwitcher.height

//BEGIN functions
    function closeApp(): void {
        delegate.window.closeWindow();
    }

    function activateApp(): void {
        if (!ShellSettings.Settings.convergenceModeEnabled) {
            delegate.window.setMaximize(true, true);
        }
        delegate.taskSwitcherHelpers.openApp(model.index);
    }

    function minimizeApp(): void {
        delegate.window.minimized = true;
    }
//END functions

    MouseArea {
        id: control
        width: delegate.width
        height: delegate.height

        // set cursor shape here, since taphandler seems to not be able to do it
        cursorShape: Qt.PointingHandCursor

        property bool movingUp: false
        property real oldY: y
        onYChanged: {
            movingUp = y < oldY;
            oldY = y;
        }

        onClicked: {
            if (!passedDragThreshold) {
                delegate.activateApp();
            }
        }

        // pixels before we start treating it as drag event
        readonly property real dragThreshold: 5

        property real startPosition: 0
        property bool hasStartPosition: false
        property bool passedDragThreshold: false

        onPositionChanged: (mouse) => {
            // map it to the root area, so that it doesn't jitter (since this item is moving)
            const yPos = control.mapToItem(delegate, mouse.x, mouse.y).y

            // reset start position
            if (!hasStartPosition) {
                startPosition = yPos;
                hasStartPosition = true;
            }

            // set threshold
            if (!passedDragThreshold && Math.abs(y) > dragThreshold) {
                passedDragThreshold = true;
            }

            // update position
            // y < 0 - dragging up (dismissing the app)
            y = Math.min(0, yPos - startPosition);
        }

        onPressedChanged: {
            yAnimator.stop();

            // reset values
            if (pressed) {
                hasStartPosition = false;
                passedDragThreshold = false;
            }

            // run animation when finger lets go
            if (!pressed) {
                if (control.movingUp && control.y < -Kirigami.Units.gridUnit * 2) {
                    yAnimator.to = -control.height;
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
            running: !control.pressed
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
            to: 0
            onFinished: {
                if (to != 0) { // close app
                    delegate.taskSwitcherHelpers.lastClosedTask = delegate.currentIndex;
                    delegate.closeApp();
                    uncloseTimer.start();
                }
            }
        }

        // application
        ColumnLayout {
            id: column
            anchors.fill: control
            spacing: 0

            // header
            RowLayout {
                id: appHeader

                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: column.height - appView.height
                spacing: Kirigami.Units.smallSpacing * 2
                opacity: delegate.showHeader ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: Kirigami.Units.shortDuration }
                }

                Kirigami.Icon {
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    Layout.alignment: Qt.AlignVCenter
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
                    icon.width: Kirigami.Units.iconSizes.smallMedium
                    icon.height: Kirigami.Units.iconSizes.smallMedium
                    onClicked: {
                        delegate.taskSwitcherHelpers.lastClosedTask = delegate.currentIndex;
                        delegate.closeApp()
                    }
                }
            }

            // app preview
            Rectangle {
                id: appView
                Layout.preferredWidth: delegate.taskSwitcherHelpers.previewWidth
                Layout.preferredHeight: delegate.taskSwitcherHelpers.previewHeight
                Layout.maximumWidth: delegate.taskSwitcherHelpers.previewWidth
                Layout.maximumHeight: delegate.taskSwitcherHelpers.previewHeight

                radius: Kirigami.Units.largeSpacing
                color: Qt.rgba(0, 0, 0, 0.2)
                clip: true

                // scale animation on press
                property real zoomScale: control.pressed ? 0.95 : 1
                Behavior on zoomScale {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
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
                    anchors.fill: appView

                    KWinComponents.WindowThumbnail {
                        id: thumbSource
                        wId: delegate.window.internalId
                        anchors.fill: item

                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: Qt.rgba(0, 0, 0, delegate.darken)
                        }
                    }
                }
            }
        }
    }
}


