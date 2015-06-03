/*
 *  Copyright 2012 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

PlasmaCore.FrameSvgItem {
    id: root
    width: 640
    height: 132
    imagePath: "widgets/panel-background"
    enabledBorders: PlasmaCore.FrameSvg.BottomBorder

    state: "Hidden"

    visible: false

    property Item containment

    onContainmentChanged: {
        print("New panel Containment: " + containment);
        containment.parent = containmentParent;
        containment.visible = true;
        containment.anchors.fill = containmentParent;
        containmentParent.anchors.bottomMargin = Math.min(root.margins.bottom, Math.max(1, root.height - units.iconSizes.smallMedium));
        visible = true
    }

    MouseEventListener {
        z: 999
        anchors.fill: parent
        property int oldMouseY
        onPressed: {
            topSlidingPanel.visible = true;
            root.state = "draggingFromClosed";
            oldMouseY = mouse.screenY;
            topSlidingPanel.raise();
        }
        onPositionChanged: {
            topSlidingPanel.y = Math.min(0, topSlidingPanel.y + mouse.screenY - oldMouseY);
            oldMouseY = mouse.screenY;
        }
        onReleased: {

            // if more than half of pick & launch panel is visible then make it totally visible.
            if (topSlidingPanel.y > -(topSlidingPanel.height - windowListContainer.height)/2) {
                //the biggest one, Launcher
                root.state = "Launcher"
            } else if (topSlidingPanel.height + topSlidingPanel.y > (windowListContainer.height / 5) * 6) {
                //show only the taskbar: require a smaller quantity of the screen uncovered when the previous state is hidden
                root.state = "Tasks"
            } else {
                //Only the small top panel
                root.state = "Hidden"
            }
        }

        Item {
            id: containmentParent
            anchors {
                fill: parent
                bottomMargin: root.margins.bottom
            }
        }
    }

    PlasmaCore.Dialog {
        id: topSlidingPanel
        visible: false
        location: PlasmaCore.Types.TopEdge
        type: PlasmaCore.Dialog.Dock
        hideOnWindowDeactivate: true
        onYChanged: panel.distance + y + height

        mainItem: MouseEventListener {
            width: root.width
            height: Screen.desktopAvailableHeight * 0.9

            property int oldMouseY
            property string oldState

            onPressed: {
                oldState = root.state;
                var startY = topSlidingPanel.y;
                root.state = "draggingFromOpen";
                topSlidingPanel.y = startY;
                oldMouseY = mouse.screenY;
            }
            onPositionChanged: {
                topSlidingPanel.y = Math.min(0, topSlidingPanel.y + mouse.screenY - oldMouseY);
                oldMouseY = mouse.screenY;
            }
            onReleased: {

                // if more than half of pick & launch panel is visible then make it totally visible.
                if ((topSlidingPanel.y > -(topSlidingPanel.height - windowListContainer.height)/2) ) {
                    //the biggest one, Launcher
                    root.state = "Launcher"
                } else if ((oldState == "Hidden" && topSlidingPanel.height + topSlidingPanel.y > windowListContainer.height/2) ||
                        (topSlidingPanel.height + units.gridUnit * 2 + topSlidingPanel.y > (windowListContainer.height / 5) * 4)) {
                    //show only the taskbar: require a smaller quantity of the screen uncovered when the previous state is hidden
                    root.state = "Tasks"
                } else {
                    //Only the small top panel
                    root.state = "Hidden"
                }
            }
            PlasmaComponents.ToolButton {
                anchors.right: parent.right
                flat: false
                z: 999
                iconSource: "window-close"
                width: units.iconSizes.medium
                height: width
                onClicked: root.state = "Hidden"
            }
            ColumnLayout {
                anchors {
                    fill: parent
                }
                ApplicationList {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    width: parent.width
                }
                WindowList {
                    id: windowListContainer
                    Layout.fillWidth: true
                    height: units.gridUnit * 15
                }
                Item {
                    Layout.minimumHeight: units.gridUnit * 2
                }
            }
        }
    }

    states:  [
        State {
            name: "Launcher"
            PropertyChanges {
                target: topSlidingPanel
                y: 0
                visible: true
            }
        },
        State {
            name: "Hidden"
            PropertyChanges {
                target: topSlidingPanel
                y: -topSlidingPanel.height
                visible: false
            }
        },
        State {
            name: "Tasks"
            PropertyChanges {
                target: topSlidingPanel
                y: -topSlidingPanel.height + windowListContainer.height + units.gridUnit * 2
                visible: true
            }
        },
        State {
            name: "draggingFromOpen"
            PropertyChanges {
                target: topSlidingPanel
                visible: true
            }
        },
        State {
            name: "draggingFromClosed"
            PropertyChanges {
                target: topSlidingPanel
                y: -topSlidingPanel.height + units.gridUnit * 5
                visible: true
            }
        }
    ]
    transitions: [
        Transition {
            to: "draggingFromOpen"
        },
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    properties: "y"
                    duration: units.longDuration
                    easing.type: Easing.OutQuad
                }
            }
        }
    ]
}
