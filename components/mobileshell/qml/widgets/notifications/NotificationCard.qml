// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root

    default property Item contentItem

    property bool tapEnabled: false

    property bool swipeGestureEnabled: false

    property real dragOffset: 0

    signal tapped()
    signal dismissRequested()
    signal configureClicked() // TODO implement settings button

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
        shadowOpacity: 0.5
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
            return Qt.rgba(darkerBackgroundColor.r, darkerBackgroundColor.g, darkerBackgroundColor.b, 0.3)
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

        implicitHeight: contentParent.implicitHeight

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r * 0.95, Kirigami.Theme.backgroundColor.g * 0.95, Kirigami.Theme.backgroundColor.b * 0.95, (root.tapEnabled && mouseArea.pressed) ? 0.95 : 0.85)
            radius: Kirigami.Units.cornerRadius
            layer.enabled: true
            layer.effect: MultiEffect {
                brightness: 0.075
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
                let threshold = Kirigami.Units.gridUnit * 5; // drag threshold
                if (root.dragOffset > threshold) {
                    dragAnim.to = root.width;
                } else if (root.dragOffset < -threshold) {
                    dragAnim.to = -root.width;
                } else {
                    dragAnim.to = 0;
                }
                dragAnim.restart();
            }
        }
    }
}
