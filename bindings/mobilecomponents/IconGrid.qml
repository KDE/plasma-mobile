/*
    Copyright 2010 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import MobileLauncher 1.0

Item {
    id: main
    property QObject model;

    PlasmaCore.Theme {
        id:theme
    }

    Flickable {
        id: mainFlickable
        interactive:true
        contentWidth: container.width; contentHeight: container.height
        anchors.fill: parent
        clip: true
        anchors.topMargin: 32
        anchors.bottomMargin: 128
        anchors.leftMargin: 4
        anchors.rightMargin: 4


        Column {
            id: container
            width: mainFlickable.width
            Component.onCompleted: {
                mainFlickable.contentY = searchFieldContainer.height
            }

            Item {
                id: searchFieldContainer
                width: parent.width
                height: 128
                PlasmaCore.FrameSvgItem {
                    id : background
                    imagePath: "widgets/lineedit"
                    prefix: "base"

                    width: 300
                    height: 35
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    TextInput {
                        id: searchField
                        anchors.fill:parent
                        anchors.leftMargin: background.margins.left
                        anchors.rightMargin: background.margins.right
                        anchors.topMargin: background.margins.top
                        anchors.bottomMargin: background.margins.bottom
                        onTextChanged: {
                            searchTimer.running = true
                        }
                    }
                    PropertyAnimation {
                        id: hideSearchFieldAnim
                        target: mainFlickable
                        properties: "contentY"
                        duration: 300
                    }
                    Timer {
                        id: searchTimer
                        interval: 500;
                        running: false
                        repeat: false
                        onTriggered: {
                            if (searchField.text == "") {
                                clearButton.visible = false
                                main.model.setQuery(main.model.defaultQuery)
                            } else {
                                clearButton.visible = true
                                main.model.setQuery(searchField.text)
                            }
                            hideSearchFieldAnim.to = searchFieldContainer.height;
                            hideSearchFieldAnim.running = true;
                        }
                    }
                    PlasmaWidgets.IconWidget {
                        id: clearButton
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: -10
                        visible: false
                        size: "64x64"
                        Component.onCompleted: {
                            setIcon("edit-clear-locationbar-rtl")
                        }
                        onClicked: {
                            searchField.text = ""
                        }
                    }
                }
            }
            ListView {
                id: appsView
                objectName: "appsView"
                width: mainFlickable.width
                height: mainFlickable.height

                model: Math.ceil(main.model.rowCount/18.0)
                highlightRangeMode: ListView.StrictlyEnforceRange
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem

                clip: true
                signal clicked(string url)


                delegate: Item {
                    width: appsView.width
                    height: appsView.height
                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter
                        rows: appsView.width > 600 ? 3 : 5
                        Repeater {
                            model: PagedProxyModel {
                                sourceModel: main.model
                                currentPage: index
                                pageSize: 18
                            }
                            delegate: Component {
                                Item {
                                    id: wrapper
                                    width: 120
                                    height: 120
                                    property string urlText: url

                                    PlasmaWidgets.IconWidget {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        size: "64x64"
                                        id: iconWidgt
                                        icon: decoration
                                    }
                                    Text {
                                        y: 67
                                        width: parent.width -16
                                        wrapMode:Text.Wrap
                                        horizontalAlignment: Text.AlignHCenter
                                        clip: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: display
                                        color: theme.textColor
                                    }

                                    MouseArea {
                                        id: mousearea
                                        anchors.fill: parent
                                        onClicked : {
                                            //appsView.currentIndex = index
                                            appsView.clicked(url)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: mainFlickable.bottom
        anchors.topMargin: 10
        Row {
            anchors.centerIn: parent
            spacing: 20

            Repeater {
                model: Math.ceil(main.model.rowCount/18.0)

                Rectangle {
                    y: appsView.currentIndex == index ? -2 : 0
                    width: appsView.currentIndex == index ? 10 : 6
                    height: appsView.currentIndex == index ? 10 : 6
                    radius: 4
                    smooth: true
                    color: appsView.currentIndex == index ? Qt.rgba(1,1,1,1) : Qt.rgba(1,1,1,0.6)

                    MouseArea {
                        width: 20; height: 20
                        anchors.centerIn: parent
                        onClicked: appsView.currentIndex = index
                    }
                }
            }
        }
    }
}
