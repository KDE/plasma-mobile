/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.13 as Kirigami

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

/**
 * Component that animates an app opening from a location.
 */
Item {
    id: root
    visible: false

    property alias backgroundColor: background.color
    Kirigami.ImageColors {
        id: colorGenerator
        source: icon.source
    }

    function open(splashIcon, title, x, y, sourceIconSize, color) {
        iconParent.scale = sourceIconSize/iconParent.width;
        background.scale = 0;
        backgroundParent.x = -root.width/2 + x
        backgroundParent.y = -root.height/2 + y
        icon.source = splashIcon;
        
        if (color !== undefined) {
            // Break binding to use custom color
            background.color = color
        } else {
            // Recreate binding
            background.color = Qt.binding(function() { return colorGenerator.dominant})
        }

        background.state = "open";
        
        MobileShell.HomeScreenControls.taskSwitcher.minimizeAll();
    }

    // close when an app opens
    property bool windowActive: Window.active
    onWindowActiveChanged: {
        background.state = "closed";
    }
    
    // close when homescreen requested
    Connections {
        target: MobileShell.HomeScreenControls
        function onOpenHomeScreen() {
            background.state = "closed";
        }
    }
    
    Connections {
        target: NanoShell.StartupNotifier
        enabled: NanoShell.StartupNotifier.isValid

        function onActivationStarted(appId, iconName) {
            icon.source = iconName
            background.state = "open";
        }
    }

    property alias state: background.state
    property alias icon: icon.source

    onVisibleChanged: {
        if (!visible) {
            background.state = "closed";
        }
    }

    Item {
        id: backgroundParent
        width: root.width
        height: root.height

        Item {
            id: iconParent
            z: 2
            anchors.centerIn: background
            width: PlasmaCore.Units.iconSizes.enormous
            height: width
            PlasmaCore.IconItem {
                id: icon
                anchors.fill: parent
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
            }
            DropShadow {
                anchors.fill: icon
                horizontalOffset: 0
                verticalOffset: 0
                radius: 8.0
                samples: 17
                color: "#80000000"
                source: icon
            }
        }
        
        Rectangle {
            id: background
            anchors.fill: parent

            color: colorGenerator.dominant

            state: "closed"

            states: [
                State {
                    name: "closed"
                    PropertyChanges {
                        target: root
                        visible: false
                    }
                },
                State {
                    name: "open"

                    PropertyChanges {
                        target: root
                        visible: true
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "closed"
                    SequentialAnimation {
                        ScriptAction {
                            script: { 
                                root.visible = true;
                            }
                        }
                        ParallelAnimation {
                            ScaleAnimator {
                                target: background
                                from: background.scale
                                to: 1
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            ScaleAnimator {
                                target: iconParent
                                from: iconParent.scale
                                to: 1
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            XAnimator {
                                target: backgroundParent
                                from: backgroundParent.x
                                to: 0
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.OutCubic
                            }
                            YAnimator {
                                target: backgroundParent
                                from: backgroundParent.y
                                to: 0
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            ]
        }
    }
}

