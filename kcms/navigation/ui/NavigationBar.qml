/*
    SPDX-FileCopyrightText: 2026 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    property bool taskSwitcher: false
    property real phoneRadius: 0
    property real phoneBorderWidth: 0

    function animateTaskSwitcher() {
        taskSwitcherButtonTouchFeedbackAnimation.restart();
    }

    function animateHome() {
        homeButtonTouchFeedbackAnimation.restart();
    }

    function animateClose() {
        closeButtonTouchFeedbackAnimation.restart();
    }

    function stopAnimations() {
        taskSwitcherButtonTouchFeedbackAnimation.stop();
        homeButtonTouchFeedbackAnimation.stop();
        closeButtonTouchFeedbackAnimation.stop();
        taskSwitcherButtonTouchFeedback.opacity = 0;
        homeButtonTouchFeedback.opacity = 0;
        closeButtonTouchFeedback.opacity = 0;
    }

    Rectangle {
        id: navbarBase
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Kirigami.Units.largeSpacing * 2

        radius: root.phoneRadius - root.phoneBorderWidth
        color: root.taskSwitcher ? "black" : Kirigami.Theme.backgroundColor
        opacity: root.taskSwitcher ? 0.1 : 1

        layer.enabled: true

        Rectangle {
            width: navbarBase.width
            height: navbarBase.radius
            color: navbarBase.color
        }
    }

    RowLayout {
        id: navbarButtons
        anchors.top: navbarBase.top
        anchors.bottom: navbarBase.bottom
        anchors.horizontalCenter: navbarBase.horizontalCenter

        width: Math.min(navbarBase.width * 0.7, navbarBase.height * 9)
        uniformCellSizes: true

        // task switcher button
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                id: taskSwitcherButtonTouchFeedback
                radius: height * 0.5
                anchors.fill: parent
                anchors.leftMargin: -radius
                anchors.rightMargin: -radius
                opacity: 0
                color: Kirigami.Theme.textColor
            }

            NumberAnimation {
                id: taskSwitcherButtonTouchFeedbackAnimation
                target: taskSwitcherButtonTouchFeedback
                property: "opacity"
                from: 0.1
                to: 0
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                implicitHeight: navbarButtons.height * 0.4
                implicitWidth: navbarButtons.height * 0.4
                width: implicitWidth
                height: implicitHeight
                source: "mobile-task-switcher"
            }
        }

        // home button
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                id: homeButtonTouchFeedback
                radius: height * 0.5
                anchors.fill: parent
                anchors.leftMargin: -radius
                anchors.rightMargin: -radius
                opacity: 0
                color: Kirigami.Theme.textColor
            }

            NumberAnimation {
                id: homeButtonTouchFeedbackAnimation
                target: homeButtonTouchFeedback
                property: "opacity"
                from: 0.1
                to: 0
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                implicitHeight: navbarButtons.height * 0.4
                implicitWidth: navbarButtons.height * 0.4
                width: implicitWidth
                height: implicitHeight
                source: "start-here-kde"
            }
        }

        // close app button
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                id: closeButtonTouchFeedback
                radius: height * 0.5
                anchors.fill: parent
                anchors.leftMargin: -radius
                anchors.rightMargin: -radius
                opacity: 0
                color: Kirigami.Theme.textColor
            }

            NumberAnimation {
                id: closeButtonTouchFeedbackAnimation
                target: closeButtonTouchFeedback
                property: "opacity"
                from: 0.1
                to: 0
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                implicitHeight: navbarButtons.height * 0.4
                implicitWidth: navbarButtons.height * 0.4
                width: implicitWidth
                height: implicitHeight
                source: "mobile-close-app"
            }
        }
    }
}
