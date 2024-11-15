// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root

    default property Item contentItem

    property bool popupNotification: false

    property bool inPopupDrawer: false

    property int currentPopupHeight: 0

    property real remainingTimeProgress: 1

    property bool closeTimerRunning: false

    property bool tapEnabled: false

    property bool swipeGestureEnabled: false

    property real dragOffset: 0

    signal tapped()
    signal dismissRequested()
    signal configureClicked() // TODO implement settings button
    signal dragStart()
    signal dragEnd()

    onContentItemChanged: {
        contentItem.parent = contentParent;
        contentItem.anchors.fill = contentParent;
        contentItem.anchors.margins = Kirigami.Units.largeSpacing;
        contentParent.children.push(contentItem);
    }

    implicitHeight: contentParent.implicitHeight

    NumberAnimation on dragOffset {
        id: dragAnim
        duration: Kirigami.Units.longDuration
        easing.type: Easing.OutCubic
        onFinished: {
            if (to !== 0) {
                root.dismissRequested();
            }
        }
    }

    // shadow
    MultiEffect {
        anchors.fill: mainCard
        visible: Math.abs(dragOffset) !== root.width
        source: simpleShadow
        blurMax: 16
        shadowEnabled: true
        shadowVerticalOffset: 1
        shadowOpacity: popupNotification ? 0.85 : 0.5
        shadowColor: Qt.lighter(Kirigami.Theme.backgroundColor, 0.2)
    }

    Rectangle {
        id: simpleShadow
        visible: Math.abs(dragOffset) !== root.width
        anchors.fill: mainCard
        anchors.leftMargin: -1
        anchors.rightMargin: -1
        anchors.bottomMargin: -1

        color: {
            let darkerBackgroundColor = Qt.darker(Kirigami.Theme.backgroundColor, 1.3);
            return Qt.rgba(darkerBackgroundColor.r, darkerBackgroundColor.g, darkerBackgroundColor.b, popupNotification ? 0.5 : 0.3)
        }
        radius: Kirigami.Units.cornerRadius
    }



    // card
    Item {
        id: mainCard
        anchors.left: parent.left
        anchors.leftMargin: root.dragOffset > 0 ? root.dragOffset : 0
        anchors.right: parent.right
        anchors.rightMargin: root.dragOffset < 0 ? -root.dragOffset : 0
        anchors.top: parent.top

        implicitHeight: inPopupDrawer ? currentPopupHeight : contentParent.implicitHeight
        Behavior on implicitHeight {
            NumberAnimation {
                duration: Kirigami.Units.veryLongDuration
                easing.type: Easing.OutExpo
            }
        }

        Rectangle {
            anchors.fill: parent
            color: popupNotification ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.5) :  Qt.rgba(Kirigami.Theme.backgroundColor.r * 0.95, Kirigami.Theme.backgroundColor.g * 0.95, Kirigami.Theme.backgroundColor.b * 0.95, (root.tapEnabled && mouseArea.pressed) ? 0.95 : 0.85)
            opacity: popupNotification ? 0.85 : 1
            radius: Kirigami.Units.cornerRadius
            layer.enabled: popupNotification ? false : true
            layer.effect: MultiEffect {
                brightness: 0.075
            }
        }

        ProgressBar {
            id: progress
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            width: root.width
            height: 2
            value: remainingTimeProgress

            opacity: closeTimerRunning ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutQuad
                }
            }

            background: Item

            contentItem: Item {
                implicitWidth: parent.width
                height: parent.height
                clip: true

                Rectangle {
                    width: Math.min(progress.visualPosition * (parent.width + root.dragOffset), parent.width)
                    height: Math.max(Kirigami.Units.cornerRadius * 2, parent.height)
                    topLeftRadius: Kirigami.Units.cornerRadius
                    topRightRadius: Kirigami.Units.cornerRadius
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.8)
                }
                Rectangle {
                    width: Math.min(progress.visualPosition * (parent.width + root.dragOffset), parent.width - Kirigami.Units.cornerRadius)
                    height: Math.max(Kirigami.Units.cornerRadius * 2, parent.height)
                    topLeftRadius: Kirigami.Units.cornerRadius
                    color: Kirigami.ColorUtils.linearInterpolation (Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.8)
                }
            }
        }

        // clip
        layer.enabled: true

        // ensure this is behind the content to not interfere
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                if (root.tapEnabled) {
                    root.tapped()
                }
            }
        }

        // content parent
        Item {
            id: contentParent
            anchors.top: parent.top
            anchors.left: root.dragOffset > 0 ? parent.left : undefined
            anchors.right: root.dragOffset < 0 ? parent.right : undefined

            width: root.width
            implicitHeight: contentItem.implicitHeight + contentItem.anchors.topMargin + contentItem.anchors.bottomMargin
        }
    }

    DragHandler {
        id: dragHandler
        enabled: root.swipeGestureEnabled
        yAxis.enabled: false
        xAxis.enabled: !inPopupDrawer

        property real startDragOffset: 0
        property real startPosition: 0
        property bool startActive: false

        onTranslationChanged: {
            if (startActive) {
                startDragOffset = root.dragOffset;
                startPosition = translation.x;
                startActive = false;
            }
            root.dragOffset = startDragOffset + (translation.x - startPosition);
        }

        onActiveChanged: {
            dragAnim.stop();
            startActive = active;

            if (!active) { // release event
                root.dragEnd()
                let threshold = Kirigami.Units.gridUnit * 5; // drag threshold
                if (root.dragOffset > threshold) {
                    dragAnim.to = root.width;
                } else if (root.dragOffset < -threshold) {
                    dragAnim.to = -root.width;
                } else {
                    dragAnim.to = 0;
                }
                dragAnim.restart();
            } else {
                root.dragStart()
            }
        }
    }
}
