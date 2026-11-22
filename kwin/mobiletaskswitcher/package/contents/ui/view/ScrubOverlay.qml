// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import "../logic"

/**
 * The app icons and arrows shown below the tasks in scrub mode.
 */
Item {
    id: root

    required property TaskSwitcher taskSwitcher
    readonly property TaskSwitcherGeometry geometry: taskSwitcher.geometry
    readonly property TaskSwitcherController controller: taskSwitcher.controller
    readonly property int currentTaskIndex: taskSwitcher.controller.navigator.currentTaskIndex

    readonly property bool shown: controller.isInTaskScrubMode

    // the app icons, the current one is centered
    RowLayout {
        opacity: root.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration } }

        anchors.bottom: root.bottom
        anchors.right: root.horizontalCenter
        anchors.bottomMargin: root.geometry.scrubModeBottomMargin

        anchors.rightMargin: {
            let size = Kirigami.Units.iconSizes.large + Kirigami.Units.largeSpacing * 2;
            let offset = (root.currentTaskIndex + 0.5) * size;
            return -offset;
        }
        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: root.controller.xAnimDuration
                easing.type: root.controller.xAnimEasingType
            }
        }

        spacing: Kirigami.Units.largeSpacing * 2

        layoutDirection: Qt.RightToLeft

        Repeater {
            model: root.taskSwitcher.tasksModel

            delegate: Kirigami.Icon {
                id: iconDelegate

                required property QtObject window
                required property int index

                readonly property bool isCenteredIcon: iconDelegate.index === root.currentTaskIndex
                Layout.preferredHeight: isCenteredIcon ? Kirigami.Units.iconSizes.huge : Kirigami.Units.iconSizes.large
                Layout.preferredWidth: isCenteredIcon ? Kirigami.Units.iconSizes.huge : Kirigami.Units.iconSizes.large
                Layout.alignment: Qt.AlignVCenter
                source: iconDelegate.window.icon
            }
        }
    }

    // arrows, dimmed at the ends of the task list
    RowLayout {
        opacity: root.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        anchors.bottom: root.bottom
        anchors.horizontalCenter: root.horizontalCenter
        anchors.bottomMargin: root.geometry.openedYPosition * 1 / 4

        Kirigami.Icon {
            opacity: root.currentTaskIndex == 0 ? 0.3 : 1
            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration * 2; easing.type: Easing.OutExpo } }
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Kirigami.Units.iconSizes.medium
            implicitHeight: Kirigami.Units.iconSizes.medium
            source: "draw-arrow-back"
            color: "white"
        }

        Item {
            width: root.geometry.windowWidth / 4
        }

        Kirigami.Icon {
            opacity: root.currentTaskIndex == root.taskSwitcher.tasksCount - 1 ? 0.3 : 1
            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration * 2; easing.type: Easing.OutExpo } }
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Kirigami.Units.iconSizes.medium
            implicitHeight: Kirigami.Units.iconSizes.medium
            source: "draw-arrow-forward"
            color: "white"
        }
    }
}
