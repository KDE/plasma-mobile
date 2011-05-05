/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Rectangle {
    id: background
    anchors.fill: parent
    color: Qt.rgba(0,0,0,0.4)

    state: "hidden"

    function activateItem(x, y)
    {
        var pos = entriesColumn.mapFromItem(delegate, x, y)
        print(entriesColumn.childAt(pos.x, pos.y))
    }

    MouseArea {
        anchors.fill:parent
        onClicked: background.state = "hidden"
    }

    property Item delegate
    onDelegateChanged: {
        var menuPos = delegate.mapToItem(parent, delegate.width/2-menuFrame.width/2, delegate.height)
        menuFrame.x = menuPos.x
        menuFrame.y = menuPos.y
    }

    PlasmaCore.Svg {
        id: lineSvg
        imagePath: "widgets/line"
    }

    PlasmaCore.FrameSvgItem {
        id: menuFrame
        imagePath: "dialogs/background"
        width: entriesColumn.width + margins.left + margins.right
        height: entriesColumn.height + margins.top + margins.bottom

        Column {
            id: entriesColumn
            x: menuFrame.margins.left
            y: menuFrame.margins.top
            Text {
                text: "Share on Dropbox"
            }
            PlasmaCore.SvgItem {
                svg: lineSvg
                elementId: "horizontal-line"
                width: entriesColumn.width
                height: lineSvg.elementSize("horizontal-line").height
            }
            Text {
                text: "Add to current Activity"
            }
        }
    }

    states: [
        State {
            name: "show"
            PropertyChanges {
                target: background
                opacity: 1
            }
            PropertyChanges {
                target: menuFrame
                scale: 1
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: background
                opacity: 0
            }
            PropertyChanges {
                target: menuFrame
                scale: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "show"
            to: "hidden"
            ParallelAnimation {
                NumberAnimation {
                    targets: background
                    properties: "opacity"
                    duration: 250
                    easing.type: "InOutCubic"
                }
                NumberAnimation {
                    targets: menuFrame
                    properties: "scale"
                    duration: 250
                    easing.type: "InOutCubic"
                }
            }
        },
        Transition {
            from: "hidden"
            to: "show"
            ParallelAnimation {
                NumberAnimation {
                    targets: background
                    properties: "opacity"
                    duration: 250
                    easing.type: "InOutCubic"
                }
                NumberAnimation {
                    targets: menuFrame
                    properties: "scale"
                    duration: 250
                    easing.type: "InOutCubic"
                }
            }
        }
    ]
}
