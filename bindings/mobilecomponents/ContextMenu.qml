/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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

Item {
    id: contextMenu
    anchors.fill: parent

    state: "hidden"
    onStateChanged: {
        if (state == "hidden") {
            //delegate.setDarkenVisible(false)
        }
    }

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.bookmarks"
        interval: 0
    }


    function activateItem(x, y)
    {
        var pos = entriesColumn.mapFromItem(delegate, x, y)
        var item = entriesColumn.childAt(pos.x, pos.y)
        print("---------------------------" + item + pos);
        if (item && typeof item != "undefined") {
            print("You clicked " + item.text)
            if (item.text == "rate") {
                print("YYY Let's rate!");
                rateResource(resourceUrl, 6);
            }
            feedbackMessageText.text = item.text
            feedbackMessageAnimation.running = true
            //item.activated()
        }
        print("bla");
    }

    function highlightItem(x, y)
    {
        var pos = entriesColumn.mapFromItem(delegate, x, y)
        var item = entriesColumn.childAt(pos.x, pos.y)
        if (item && item.text) {
            var itemPos = menuFrame.mapFromItem(item, 0, 0)
            highlightFrame.x = -highlightFrame.margins.right + itemPos.x
            highlightFrame.y = -highlightFrame.margins.top + itemPos.y
            highlightFrame.width = entriesColumn.width + highlightFrame.margins.right + highlightFrame.margins.left
            highlightFrame.height = item.height + highlightFrame.margins.top + highlightFrame.margins.bottom
            highlightFrame.opacity = 1
        } else {
            highlightFrame.opacity = 0
        }
    }

    function rateResource(resourceUrl, rating) {
        print("YYY Rating " + resourceUrl + " *****: " + rating )

        var service = metadataSource.serviceForSource("anything")
        var operation = service.operationDescription("rate")

        operation["ResourceUrl"] = resourceUrl;
        operation["Rating"] = rating;
        service.startOperationCall(operation)

        /*
        engine = dataEngine("notifications");
        service = engine.serviceForSource("notification");
        op = service.operationDescription("createNotification");
        operation["resourceUrl"] = "foo";
        operation["rating"] = rating;
        op["summary"] = "this is a summary";
        op["body"] = "body of notification";
        op["timeout"] = 2000;

        service.startOperationCall(op);
        */
    }

    MouseArea {
        anchors.fill: parent
        onClicked: contextMenu.state = "hidden"
    }

    property string resourceType
    property string source
    property string resourceUrl

    property Item delegate
    onDelegateChanged: {
        positionMenu()
        highlightFrame.opacity = 0
    }

    function positionMenu()
    {
        var menuPos = delegate.mapToItem(parent, delegate.width/2-menuObject.width/2, delegate.height)

        if (menuPos.y > contextMenu.height/2) {
            menuPos = delegate.mapToItem(parent, delegate.width/2-menuObject.width/2, -menuFrame.height)
            tipSvgItem.state = "top"
        } else {
            tipSvgItem.state = "bottom"
        }

        menuObject.x = menuPos.x
        menuObject.y = menuPos.y
    }

    MobileComponents.ActionsModel {
        id: actionsModel
    }

    PlasmaCore.Svg {
        id: lineSvg
        imagePath: "widgets/line"
    }

    PlasmaCore.Svg {
        id: tipSvg
        imagePath: "dialogs/background"
    }

    Item {
        id: menuObject
        width: menuFrame.width
        height: 1

        PlasmaCore.SvgItem {
            id: tipSvgItem
            svg: tipSvg
            elementId: "baloon-tip-top"
            width: tipSvg.elementSize(elementId).width
            height: tipSvg.elementSize(elementId).height
            state: "top"
            z: 900
            anchors {
                horizontalCenter: menuFrame.horizontalCenter
                bottomMargin: -tipSvg.elementSize("hint-top-shadow").height
                topMargin: -tipSvg.elementSize("hint-bottom-shadow").height
            }

            states: [
                State {
                    name: "top"
                    PropertyChanges {
                        target: tipSvgItem
                        elementId: "baloon-tip-bottom"
                    }
                    AnchorChanges {
                        target: tipSvgItem
                        anchors.top: menuFrame.bottom
                    }
                },
                State {
                    name: "bottom"
                    PropertyChanges {
                        target: tipSvgItem
                        elementId: "baloon-tip-top"
                    }
                    AnchorChanges {
                        target: tipSvgItem
                        anchors.bottom: menuFrame.top
                    }
                }
            ]
        }

        PlasmaCore.FrameSvgItem {
            id: menuFrame
            imagePath: "dialogs/background"
            width: entriesColumn.width + margins.left + margins.right + highlightFrame.margins.left + highlightFrame.margins.right
            height: entriesColumn.height + margins.top + margins.bottom + highlightFrame.margins.top + highlightFrame.margins.bottom
            onHeightChanged: positionMenu()

            PlasmaCore.FrameSvgItem {
                id: highlightFrame
                imagePath: "widgets/viewitem"
                prefix: "hover"
                opacity: 0
                Behavior on y {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Column {
                id: entriesColumn
                x: menuFrame.margins.left + highlightFrame.margins.left
                y: menuFrame.margins.top + highlightFrame.margins.top
                spacing: 5

                Repeater {
                    model: actionsModel.model(resourceType)

                    Column {
                        spacing: 5
                        property alias text: menuItem.text

                        MobileComponents.MenuItem {
                            id: menuItem
                            text: model.text
                        }
                        PlasmaCore.SvgItem {
                            svg: lineSvg
                            elementId: "horizontal-line"
                            width: entriesColumn.width
                            height: lineSvg.elementSize("horizontal-line").height
                        }
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "show"
            PropertyChanges {
                target: contextMenu
                opacity: 1
            }
            PropertyChanges {
                target: menuObject
                scale: 1
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: contextMenu
                opacity: 0
            }
            PropertyChanges {
                target: menuObject
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
                    targets: contextMenu
                    properties: "opacity"
                    duration: 250
                    easing.type: "InOutElastic"
                }
                NumberAnimation {
                    targets: menuObject
                    properties: "scale"
                    duration: 250
                    easing.type: "InOutElastic"
                }
            }
        },
        Transition {
            from: "hidden"
            to: "show"
            ParallelAnimation {
                NumberAnimation {
                    targets: contextMenu
                    properties: "opacity"
                    duration: 400
                    easing.type: "InOutElastic"
                }
                NumberAnimation {
                    targets: menuObject
                    properties: "scale"
                    duration: 800
                    easing.type: "InOutElastic"
                }
            }
        }
    ]

    PlasmaCore.FrameSvgItem {
        id: feedbackMessage
        imagePath: "dialogs/background"
        width: feedbackMessageText.width + margins.left + margins.right
        height: feedbackMessageText.height + margins.top + margins.bottom
        anchors.centerIn: parent
        Text {
            id: feedbackMessageText
            x: feedbackMessage.margins.left
            y: feedbackMessage.margins.top
            font.bold: true
            font.pixelSize: 20
        }
        scale: 0
    }

    SequentialAnimation {
        id: feedbackMessageAnimation
        NumberAnimation {
            target: feedbackMessage
            properties: "scale"
            to: 1
            duration: 300
        }
        PauseAnimation {
            duration: 500
        }
        NumberAnimation {
            target: feedbackMessage
            properties: "scale"
            to: 0
            duration: 300
        }
        ScriptAction {
            script: contextMenu.state = "hidden"
        }
    }
}

