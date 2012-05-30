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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents


Item {
    id: main

    property Component delegate
    property QtObject model
    property int pageSize: Math.floor(iconView.width/main.delegateWidth)*Math.floor(iconView.height/main.delegateHeight)
    property int delegateWidth: theme.defaultFont.mSize.width * 15
    property int delegateHeight: theme.defaultIconSize + theme.defaultFont.mSize.height + 8
    property alias currentPage: iconView.currentIndex
    property int pagesCount: Math.ceil(model.count/pageSize)
    property int count: model.count

    function pageForIndex(index)
    {
        return Math.floor(index / pageSize)
    }

    function positionViewAtIndex(index)
    {
        iconView.positionViewAtIndex(index / pageSize, ListView.Beginning)
    }

    function positionViewAtPage(page)
    {
        iconView.positionViewAtIndex(page, ListView.Beginning)
    }

    PlasmaCore.Theme {
        id:theme
    }


    Timer {
        id: resizeTimer
        running: true
        interval: 100
        onTriggered: {
            main.pageSize = Math.floor(iconView.width/main.delegateWidth)*Math.floor(iconView.height/main.delegateHeight)
            if (iconView.currentItem) {
                iconView.currentItem.width = iconView.width
                iconView.currentItem.height = iconView.height
            }
        }
    }
    ListView {
        id: iconView
        objectName: "iconView"
        pressDelay: 200
        cacheBuffer: 100
        highlightMoveDuration: 250
        anchors.fill: parent
        onWidthChanged: resizeTimer.restart()
        onHeightChanged: resizeTimer.restart()

        model: main.model ? Math.ceil(main.model.count/main.pageSize) : 0
        highlightRangeMode: ListView.StrictlyEnforceRange
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.DragOverBounds

        clip: true
        signal clicked(string url)

        delegate: Component {
            Item {
                id: delegatePage
                //Explicitly *not* bind the properties for performance reasons
                Component.onCompleted: {
                    width = iconView.width
                    height = iconView.height
                    //iconView.cacheBuffer = iconView.width
                }

                Flow {
                    id: iconFlow
                    width: iconRepeater.suggestedWidth

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        bottom: parent.bottom
                    }
                    property int orientation: ListView.Horizontal

                    MobileComponents.PagedProxyModel {
                        id: pagedProxyModel
                        sourceModel: main.model
                        currentPage: index
                        pageSize: main.pageSize
                    }
                    Timer {
                        id: loadTimer
                        repeat: false
                        interval: 0
                        onTriggered: iconRepeater.model = pagedProxyModel
                        Component.onCompleted: {
                            loadTimer.interval = iconView.moving ? 500 : 0
                            loadTimer.running = true
                        }
                    }
                    Repeater {
                        id: iconRepeater
                        property int columns: Math.min(count, Math.floor(delegatePage.width/main.delegateWidth))
                        property int suggestedWidth: main.delegateWidth*columns
                        //property int suggestedHeight: main.delegateHeight*Math.floor(count/columns)

                        delegate: main.delegate
                    }
                }
            }
        }
    }


    Loader {
        id: scrollArea
        visible: main.model && Math.ceil(main.model.count/main.pageSize) > 1
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: Math.max( 16, iconView.height - Math.floor(iconView.height/delegateHeight)*delegateHeight)

        property int pageCount: main.model ? Math.ceil(main.model.count/main.pageSize) : 0

        sourceComponent: pageCount > 1 ? ((pageCount * 20 > width) ? scrollDotComponent : dotsRow) : undefined
        function setViewIndex(index)
        {
            //animate only if near
            if (Math.abs(iconView.currentIndex - index) > 1) {
                iconView.positionViewAtIndex(index, ListView.Beginning)
            } else {
                iconView.currentIndex = index
            }
        }
        Component {
            id: scrollDotComponent
            MouseArea {
                anchors.fill: parent
                property int pendingIndex: 0
                Rectangle {
                    id: barRectangle
                    color: theme.textColor
                    opacity: 0.25
                    height: 4
                    radius: 2
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: (parent.width/pageCount/2)
                        rightMargin: (parent.width/pageCount/2)
                    }
                }
                Rectangle {
                    color: theme.textColor
                    height: 8
                    width: height
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.width/(pageCount/(iconView.currentIndex+1)) - (parent.width/pageCount/2) - 4
                    Behavior on x {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                function setViewIndexFromMouse(x)
                {
                    pendingIndex = Math.min(pageCount,
                                            Math.round(pageCount / (barRectangle.width / Math.max(x - barRectangle.x, 1))))
                    viewPositionTimer.restart()
                }
                onPressed: setViewIndexFromMouse(mouse.x)
                onPositionChanged: setViewIndexFromMouse(mouse.x)

                Timer {
                    id: viewPositionTimer
                    interval: 200
                    onTriggered: setViewIndex(pendingIndex)
                }
            }
        }
        Component {
            id: dotsRow

            Item {
                Row {
                    anchors.centerIn: parent
                    spacing: 20

                    Repeater {
                        model: scrollArea.pageCount


                        Rectangle {
                            width: 6
                            height: 6
                            scale: iconView.currentIndex == index ? 1.5 : 1
                            radius: 5
                            smooth: true
                            opacity: iconView.currentIndex == index ? 0.8: 0.4
                            color: theme.textColor

                            Behavior on scale {
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

                            MouseArea {
                                anchors {
                                    fill: parent
                                    margins: -10
                                }

                                onClicked: {
                                    setViewIndex(index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
