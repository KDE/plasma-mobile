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

Item {
    id: sliderItem
    state: "hidden"
    property alias sliderLabel: sliderText.text
    property alias sliderMessage: sliderMessageText.text
    signal activated
    anchors {
        verticalCenter: parent.verticalCenter
        right: parent.right
    }
    width: 240
    height: 32
    Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    Image {
        id: holeImage
        y: 4
        source: plasmoid.file("images", "sliderhole.png")
        anchors.left: parent.left
        Text {
            id: sliderMessageText
            anchors.centerIn: parent
            text: "Slide to activate"
        }
    }
    Image {
        id: handleImage
        x: model["Current"]==true?-4:parent.width - width
        source: plasmoid.file("images", "slider.png")
        Text {
            id: sliderText
            anchors.centerIn: parent
            font.pixelSize: 14
        }
        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }
    MouseArea {
        anchors.fill: handleImage
        drag.target: handleImage
        drag.axis: Drag.XAxis
        drag.minimumX: holeImage.x - 4
        drag.maximumX: handleImage.parent.width - width

        onClicked: {
            for (var i = 0; i < categoriesFlow.children.length; ++i) {
                var child = categoriesFlow.children[i]
                if (child.currentIndex != undefined && child != itemGroup) {
                    child.currentIndex = -1
                }
            }
            elementsView.currentIndex = index
            slcRow.delegate = resourceDelegate
        }

        onPressed: {
            mouse.accepted = true
            sliderItem.parent.z = 999
            sliderItem.state = "shown"
            elementsView.interactive = false
        }
        onReleased: {
            if (handleImage.x <= holeImage.x) {
                sliderItem.activated()
                for (var i = 0; i < categoriesFlow.children.length; ++i) {
                    var child = categoriesFlow.children[i]
                    if (child.currentIndex != undefined && child != itemGroup) {
                        child.currentIndex = -1
                    }
                }
                elementsView.currentIndex = index
                slcRow.delegate = resourceDelegate
            }
            sliderItem.parent.z = 0
            sliderItem.state = "hidden"
            handleImage.x = handleImage.parent.width - width
            elementsView.interactive = true
        }
    }

    states: [
        State {
            name: "shown"
            PropertyChanges {
                target: holeImage
                opacity: 1
            }
            PropertyChanges {
                target: handleImage
                opacity: 1
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: holeImage
                opacity: 0
            }
            PropertyChanges {
                target: handleImage
                opacity: 0
            }
        }
    ]
    transitions: [
        Transition {
            from: "shown"
            to: "hidden"
            ParallelAnimation {
                NumberAnimation {
                    targets: holeImage
                    properties: "opacity"
                    duration: 250
                    easing.type: "InOutCubic"
                }
                NumberAnimation {
                    targets: handleImage
                    properties: "opacity"
                    duration: 250
                    easing.type: "InOutCubic"
                }
            }
        },
        Transition {
            from: "hidden"
            to: "shown"
            ParallelAnimation {
                NumberAnimation {
                    targets: holeImage
                    properties: "opacity"
                    duration: 250
                    easing.type: "InOutCubic"
                }
                NumberAnimation {
                    targets: handleImage
                    properties: "opacity"
                    duration: 250
                    easing.type: "InOutCubic"
                }
            }
        }
    ]
}
