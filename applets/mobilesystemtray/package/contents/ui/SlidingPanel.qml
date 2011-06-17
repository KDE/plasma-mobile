/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

PlasmaCore.Dialog {
    id: slidingPanel
    property alias menuPlasmoid: menuContainer.applet
    property alias windowListPlasmoid: windowListContainer.applet
    property alias state: containerColumn.state


    mainItem: Column {
        id: containerColumn
        width: 1024
        height: 550
        state: "Hidden"
        PlasmoidContainer {
            id: menuContainer
            anchors {
                left: parent.left
                right: parent.right
            }
            height: 350
            onHeightChanged: {
                applet.height = height
            }
            onWidthChanged: {
                applet.width = width
            }
        }
        PlasmoidContainer {
            id: windowListContainer
            anchors {
                left: parent.left
                right: parent.right
            }
            height: 150
            onHeightChanged: {
                applet.height = height
            }
            onWidthChanged: {
                applet.width = width
            }
        }
        states:  [
            State {
                name: "Full"
                PropertyChanges {
                    target: slidingPanel
                    y: main.height
                    visible: true
                }
            },
            State {
                name: "Hidden"
                PropertyChanges {
                    target: slidingPanel
                    y: -slidingPanel.height
                    visible: false
                }
            },
            State {
                name: "Peek"
                PropertyChanges {
                    target: slidingPanel
                    y: -slidingPanel.height + main.height + 20
                    visible: true
                }
            },
            State {
                name: "Tasks"
                PropertyChanges {
                    target: slidingPanel
                    y: -slidingPanel.height + windowListContainer.height + main.height +20
                    visible: true
                }
            }
        ]
        transitions: [
            Transition {
                from: "Hidden"
                SequentialAnimation {
                    PropertyAction {
                        target: slidingPanel
                        properties: "visible"
                        value: true
                    }
                    PropertyAnimation {
                        properties: "y"
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            },
            Transition {
                to: "Hidden"
                SequentialAnimation {
                    PropertyAnimation {
                        properties: "y"
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                    PropertyAction {
                        target: slidingPanel
                        properties: "visible"
                        value: false
                    }
                }
            },
            Transition {
                PropertyAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        ]
    }
}
