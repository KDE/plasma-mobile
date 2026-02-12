/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.mobileshell.state as MobileShellState

Item {
    id: root

    property bool shadow: false
    property color backgroundColor
    property var foregroundColorGroup

    property NavigationPanelAction leftAction
    property NavigationPanelAction middleAction
    property NavigationPanelAction rightAction

    property NavigationPanelAction leftCornerAction
    property NavigationPanelAction rightCornerAction

    property real leftPadding: 0
    property real rightPadding: 0

    property bool isVertical: false

    // drop shadow for icons
    MultiEffect {
        anchors.fill: icons
        visible: shadow
        source: icons
        blurMax: 16
        shadowEnabled: true
        shadowVerticalOffset: 1
        shadowOpacity: 0.8
    }

    // background colour
    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
    }

    Item {
        id: icons
        anchors.fill: parent

        property real buttonLength: 0

        NavigationPanelButton {
            id: leftCornerButton
            visible: root.leftCornerAction.visible
            Kirigami.Theme.colorSet: root.foregroundColorGroup
            Kirigami.Theme.inherit: false
            enabled: root.leftCornerAction.enabled
            shrinkSize: root.leftCornerAction.shrinkSize
            iconSource: root.leftCornerAction.iconSource
            onClicked: {
                if (enabled) {
                    root.leftCornerAction.triggered();
                }
            }
        }

        // button row (anchors provided by state)
        NavigationPanelButton {
            id: leftButton
            visible: root.leftAction.visible
            Kirigami.Theme.colorSet: root.foregroundColorGroup
            Kirigami.Theme.inherit: false
            enabled: root.leftAction.enabled
            shrinkSize: root.leftAction.shrinkSize
            iconSource: root.leftAction.iconSource
            onClicked: {
                if (enabled) {
                    root.leftAction.triggered();
                }
            }
        }

        NavigationPanelButton {
            id: middleButton
            anchors.centerIn: parent
            visible: root.middleAction.visible
            Kirigami.Theme.colorSet: root.foregroundColorGroup
            Kirigami.Theme.inherit: false
            enabled: root.middleAction.enabled
            shrinkSize: root.middleAction.shrinkSize
            iconSource: root.middleAction.iconSource
            onClicked: {
                if (enabled) {
                    root.middleAction.triggered();
                }
            }
        }

        NavigationPanelButton {
            id: rightButton
            visible: root.rightAction.visible
            Kirigami.Theme.colorSet: root.foregroundColorGroup
            Kirigami.Theme.inherit: false
            enabled: root.rightAction.enabled
            shrinkSize: root.rightAction.shrinkSize
            iconSource: root.rightAction.iconSource
            onClicked: {
                if (enabled) {
                    root.rightAction.triggered();
                }
            }
        }

        NavigationPanelButton {
            id: rightCornerButton
            visible: root.rightCornerAction.visible
            Kirigami.Theme.colorSet: root.foregroundColorGroup
            Kirigami.Theme.inherit: false
            enabled: root.rightCornerAction.enabled
            shrinkSize: root.rightCornerAction.shrinkSize
            iconSource: root.rightCornerAction.iconSource
            onClicked: {
                if (enabled) {
                    root.rightCornerAction.triggered();
                }
            }
        }
    }

    states: [
        State {
            name: "vertical"
            when: root.isVertical
            PropertyChanges {
                target: icons
                anchors {
                    topMargin: root.leftPadding
                    bottomMargin: root.rightPadding
                }
                buttonLength: Math.min(Kirigami.Units.gridUnit * 10, icons.height * 0.7 / 3)
            }
            AnchorChanges {
                target: leftButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: middleButton.bottom
                }
            }
            PropertyChanges {
                target: leftButton
                width: parent.width
                height: icons.buttonLength
            }
            PropertyChanges {
                target: middleButton
                width: parent.width
                height: icons.buttonLength
            }
            AnchorChanges {
                target: rightButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: middleButton.top
                }
            }
            PropertyChanges {
                target: rightButton
                height: icons.buttonLength
                width: icons.width
            }
            AnchorChanges {
                target: rightCornerButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
            }
            PropertyChanges {
                target: rightCornerButton
                height: Kirigami.Units.gridUnit * 2
                width: icons.width
            }
            AnchorChanges {
                target: leftCornerButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
            }
            PropertyChanges {
                target: leftCornerButton
                height: Kirigami.Units.gridUnit * 2
                width: icons.width
            }
        }, State {
            name: "horizontal"
            when: !root.isVertical
            PropertyChanges {
                target: icons
                anchors {
                    leftMargin: root.leftPadding
                    rightMargin: root.rightPadding
                }
                buttonLength: Math.min(Kirigami.Units.gridUnit * 8, icons.width * 0.7 / 3)
            }
            AnchorChanges {
                target: leftButton
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: middleButton.left
                }
            }
            PropertyChanges {
                target: leftButton
                height: parent.height
                width: icons.buttonLength
            }
            PropertyChanges {
                target: middleButton
                height: parent.height
                width: icons.buttonLength
            }
            AnchorChanges {
                target: rightButton
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: middleButton.right
                }
            }
            PropertyChanges {
                target: rightButton
                height: parent.height
                width: icons.buttonLength
            }
            AnchorChanges {
                target: rightCornerButton
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }
            }
            PropertyChanges {
                target: rightCornerButton
                height: parent.height
                width: Kirigami.Units.gridUnit * 2
            }
            AnchorChanges {
                target: leftCornerButton
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
            }
            PropertyChanges {
                target: leftCornerButton
                height: parent.height
                width: Kirigami.Units.gridUnit * 2
            }
        }
    ]
}
