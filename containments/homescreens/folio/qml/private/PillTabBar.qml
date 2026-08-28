/*
    SPDX-FileCopyrightText: 2026 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls

import org.kde.kirigami as Kirigami

FocusScope {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 12
    implicitHeight: Kirigami.Units.gridUnit

    property var model
    property int currentIndex: 0
    property int count: repeater.count

    property color backgroundColor: Qt.rgba(1, 1, 1, 0.15)
    property color highlightColor: Qt.rgba(1, 1, 1, 0.2)
    property color activeHighlightColor: Qt.rgba(1, 1, 1, 0.3)
    property color textColor: Qt.rgba(1, 1, 1, 0.9)
    property color activeTextColor: "white"
    property font font
    property real padding: Kirigami.Units.smallSpacing * 0.5 // internal padding around the active pill

    property bool keyboardFocus: false // used to differentiate between pointer and keyboard focus

    signal focusUpRequested()
    signal focusDownRequested()
    signal focusNextRequested()
    signal focusPreviousRequested()

    onActiveFocusChanged: {
        // reset the keyboard focus flag when focus is completely lost
        if (!activeFocus) {
            keyboardFocus = false;
        }
    }

    // keyboard navigation
    Keys.onUpPressed: {
        focusUpRequested();
        event.accepted = true;
    }
    Keys.onDownPressed: {
        focusDownRequested();
        event.accepted = true;
    }
    Keys.onTabPressed: {
        focusNextRequested();
        event.accepted = true;
    }
    Keys.onBacktabPressed: {
        focusPreviousRequested();
        event.accepted = true;
    }

    Keys.onLeftPressed: {
        root.keyboardFocus = true; // ensure visual highlight when navigating with keyboard
        if (currentIndex > 0) {
            currentIndex--;
        }
        event.accepted = true;
    }
    Keys.onRightPressed: {
        root.keyboardFocus = true; // ensure visual highlight when navigating with keyboard
        if (currentIndex < count - 1) {
            currentIndex++;
        }
        event.accepted = true;
    }

    // tabbar main background
    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
        radius: height / 2
    }

    Row {
        anchors.fill: parent

        Repeater {
            id: repeater
            model: root.model

            delegate: Item {
                id: tabButton
                readonly property bool isCurrent: index === root.currentIndex

                width: repeater.count > 0 ? Math.floor(root.width / repeater.count) : 0
                height: root.height

                // active tab highlight pill
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: root.padding

                    color: tabButton.isCurrent ? ((root.activeFocus && root.keyboardFocus) ? root.activeHighlightColor : root.highlightColor) : "transparent"
                    radius: height / 2

                    Behavior on color {
                        ColorAnimation {
                            duration: Kirigami.Units.shortDuration
                        }
                    }
                }

                // tab text
                Text {
                    id: label
                    anchors.centerIn: parent

                    text: modelData

                    color: tabButton.isCurrent ? root.activeTextColor : root.textColor
                    font: root.font

                    width: parent.width - (root.padding * 4)
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.keyboardFocus = false; // we remove the keyboard focus highlight when the tabbar is touched or clicked on
                        root.currentIndex = index;
                        root.forceActiveFocus();
                    }
                }
            }
        }
    }
}
