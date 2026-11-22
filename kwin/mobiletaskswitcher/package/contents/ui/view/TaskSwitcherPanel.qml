// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

/**
 * The navigation panel or gesture panel shown over the task switcher, at the bottom or on the right side.
 */
Loader {
    id: root

    required property TaskSwitcher taskSwitcher

    readonly property bool onSide: MobileShell.Constants.navigationPanelOnSide(taskSwitcher.width, taskSwitcher.height)

    signal taskSwitcherRequested()
    signal homeRequested()
    signal closeCurrentTaskRequested()

    sourceComponent: {
        if (ShellSettings.Settings.navigationPanelEnabled) {
            return navigationPanelComponent;
        } else if (ShellSettings.Settings.gesturePanelEnabled) {
            return gesturePanelComponent;
        } else {
            return null;
        }
    }

    states: [
        State {
            name: "landscape"
            when: root.onSide
            AnchorChanges {
                target: root
                anchors {
                    right: root.taskSwitcher.right
                    top: root.taskSwitcher.top
                    bottom: root.taskSwitcher.bottom
                    left: undefined
                }
            }
            PropertyChanges {
                root.width: root.taskSwitcher.navRightMargin
                root.anchors.topMargin: root.taskSwitcher.topMargin
            }
        },
        State {
            name: "portrait"
            when: !root.onSide
            AnchorChanges {
                target: root
                anchors {
                    top: undefined
                    right: root.taskSwitcher.right
                    left: root.taskSwitcher.left
                    bottom: root.taskSwitcher.bottom
                }
            }
            PropertyChanges {
                root.height: root.taskSwitcher.navBottomMargin
            }
        }
    ]

    Component {
        id: gesturePanelComponent

        MobileShell.GesturePanel {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
            opaqueBar: false

            // Trigger home action on tap
            onHandleClicked: root.taskSwitcherRequested()
        }
    }

    Component {
        id: navigationPanelComponent

        MobileShell.NavigationPanel {
            backgroundColor: Qt.rgba(0, 0, 0, 0.1)
            foregroundColorGroup: Kirigami.Theme.Complementary
            shadow: false

            isVertical: root.onSide

            MobileShellState.PanelSettingsDBusClient {
                id: panelSettings
                screenName: Screen.name
            }

            leftPadding: panelSettings.navigationPanelLeftPadding
            rightPadding: panelSettings.navigationPanelRightPadding

            leftAction: MobileShell.NavigationPanelAction {
                enabled: true
                iconSource: "mobile-task-switcher"
                shrinkSize: 4

                onTriggered: root.taskSwitcherRequested()
            }

            // home button
            middleAction: MobileShell.NavigationPanelAction {
                enabled: true
                iconSource: "start-here-kde"
                onTriggered: root.homeRequested()
            }

            // close app/keyboard button
            rightAction: MobileShell.NavigationPanelAction {
                enabled: true
                iconSource: "mobile-close-app"
                shrinkSize: 4

                onTriggered: root.closeCurrentTaskRequested()
            }

            rightCornerAction: MobileShell.NavigationPanelAction {
                visible: false
            }
        }
    }
}
