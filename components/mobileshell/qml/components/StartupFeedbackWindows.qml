// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

import QtQuick
import QtQuick.Effects

import org.kde.kirigami as Kirigami

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

Item {
    id: root

    property int screen
    property real topMargin
    property real bottomMargin
    property real leftMargin
    property real rightMargin

    onScreenChanged: {
        repeater.model.setFilterFixedString(root.screen);
    }

    Component.onCompleted: {
        repeater.model.setFilterFixedString(root.screen);
    }

    Repeater {
        id: repeater
        model: MobileShellState.StartupFeedbackFilterModel {
            startupFeedbackModel: MobileShellState.ShellDBusObject.startupFeedbackModel
        }

        delegate: Item {
            Window {
                id: window

                property var startupFeedback: model.delegate

                visibility: Window.Maximized
                flags: Qt.FramelessWindowHint
                color: 'transparent'
                title: startupFeedback.title

                Component.onCompleted: {
                    // root is anchored to the homescreen which fills up the whole screen,
                    // but the startup feedback window will have margins (ex. status bar)
                    const realHeight = root.height - root.topMargin - root.bottomMargin;
                    const realWidth = root.width - root.leftMargin - root.rightMargin;

                    iconParent.scale = startupFeedback.iconSize / iconParent.width;
                    background.scale = 0;

                    if (startupFeedback.iconStartX === -1 && startupFeedback.iconStartY === -1) {
                        backgroundParent.x = 0;
                        backgroundParent.y = 0;
                    } else {
                        backgroundParent.x = -realWidth/2 + startupFeedback.iconStartX - root.leftMargin;
                        backgroundParent.y = -realHeight/2 + startupFeedback.iconStartY - root.topMargin;
                    }

                    if (ShellSettings.Settings.animationsEnabled) {
                        openAnimComplex.restart();
                    } else {
                        openAnimSimple.restart();
                    }
                }

                // animation that moves the icon
                SequentialAnimation {
                    id: openAnimComplex

                    // pause for background color to catch up
                    PauseAnimation { duration: 1 }

                    ParallelAnimation {
                        id: parallelAnim
                        property real animationDuration: Kirigami.Units.longDuration + Kirigami.Units.shortDuration

                        ScaleAnimator {
                            target: background
                            from: background.scale
                            to: 1
                            duration: parallelAnim.animationDuration
                            easing.type: Easing.OutCubic
                        }
                        ScaleAnimator {
                            target: iconParent
                            from: iconParent.scale
                            to: 1
                            duration: parallelAnim.animationDuration
                            easing.type: Easing.OutCubic
                        }
                        XAnimator {
                            target: backgroundParent
                            from: backgroundParent.x
                            to: 0
                            duration: parallelAnim.animationDuration
                            easing.type: Easing.OutCubic
                        }
                        YAnimator {
                            target: backgroundParent
                            from: backgroundParent.y
                            to: 0
                            duration: parallelAnim.animationDuration
                            easing.type: Easing.OutCubic
                        }
                    }

                    ScriptAction {
                        script: {
                            // Animation has finished, trigger event for panels to update color
                            MobileShellState.ShellDBusClient.triggerAppLaunchMaximizePanelAnimation(root.screen, background.color);

                            // close the app drawer after it isn't visible
                            MobileShellState.ShellDBusClient.resetHomeScreenPosition();
                        }
                    }
                }

                // animation that just fades in
                SequentialAnimation {
                    id: openAnimSimple

                    ScriptAction {
                        script: {
                            background.scale = 1;
                            iconParent.scale = 1;
                            backgroundParent.x = 0;
                            backgroundParent.y = 0;
                        }
                    }

                    NumberAnimation {
                        target: windowRoot
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.OutCubic
                    }

                    ScriptAction {
                        script: {
                            // Animation has finished, trigger event for panels to update color
                            MobileShellState.ShellDBusClient.triggerAppLaunchMaximizePanelAnimation(root.screen, background.color);

                            // close the app drawer after it isn't visible
                            MobileShellState.ShellDBusClient.resetHomeScreenPosition();
                        }
                    }
                }

                Item {
                    id: windowRoot
                    anchors.fill: parent

                    Item {
                        id: backgroundParent
                        width: windowRoot.width
                        height: windowRoot.height

                        Rectangle {
                            id: background
                            anchors.fill: parent

                            // Tint the background color so that it is less prominent
                            // This avoids flashing the user all of a sudden with bright colors
                            color: Kirigami.ColorUtils.tintWithAlpha(colorGenerator.dominant, Kirigami.Theme.backgroundColor, 0.7)

                            Kirigami.ImageColors {
                                id: colorGenerator
                                source: icon.source
                            }
                        }

                        Item {
                            id: iconParent
                            anchors.centerIn: background
                            width: Kirigami.Units.iconSizes.enormous
                            height: Kirigami.Units.iconSizes.enormous

                            Kirigami.Icon {
                                id: icon
                                anchors.fill: parent
                                source: window.startupFeedback.iconName
                            }

                            MultiEffect {
                                anchors.fill: icon
                                source: icon
                                shadowEnabled: true
                                blurMax: 16
                                shadowColor: "#80000000"
                            }

                            Timer {
                                running: true
                                interval: 2000
                                onTriggered: loadingIndicator.opacity = 1
                            }

                            // Show loading indicator after two seconds have passed
                            PC3.BusyIndicator {
                                id: loadingIndicator
                                anchors.top: icon.bottom
                                anchors.horizontalCenter: icon.horizontalCenter
                                anchors.topMargin: Kirigami.Units.gridUnit
                                opacity: 0

                                Behavior on opacity {
                                    NumberAnimation {}
                                }

                                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            }
                        }
                    }
                }
            }
        }
    }
}
