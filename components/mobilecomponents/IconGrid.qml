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
    property int pageSize: Math.floor(appsView.width/delegateWidth)*Math.floor(appsView.height/delegateHeight)
    property int delegateWidth: 120
    property int delegateHeight: 120
    property alias currentPage: appsView.currentIndex
    property int pagesCount: Math.ceil(model.count/pageSize)
    property int count: model.count

    function pageForIndex(index)
    {
        return Math.floor(index / pageSize)
    }

    function positionViewAtIndex(index)
    {
        appsView.positionViewAtIndex(index / pageSize, ListView.Beginning)
    }

    function positionViewAtPage(page)
    {
        appsView.positionViewAtIndex(page, ListView.Beginning)
    }

    PlasmaCore.Theme {
        id:theme
    }


    ListView {
        id: appsView
        objectName: "appsView"
        pressDelay: 200
        cacheBuffer: width*2
        highlightMoveDuration: 250
        anchors.fill: parent


        model: main.model?Math.ceil(main.model.count/main.pageSize):0
        highlightRangeMode: ListView.StrictlyEnforceRange
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.DragOverBounds

        clip: true
        signal clicked(string url)

        delegate: Component {
            Item {
                width: appsView.width
                height: appsView.height
                Flow {
                    id: iconFlow
                    width: iconRepeater.suggestedWidth

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        bottom: parent.bottom
                    }
                    property int orientation: ListView.Horizontal

                    Repeater {
                        id: iconRepeater
                        property int columns: Math.min(count, Math.floor(appsView.width/main.delegateWidth))
                        property int suggestedWidth: main.delegateWidth*columns
                        //property int suggestedHeight: main.delegateHeight*Math.floor(count/columns)

                        model: MobileComponents.PagedProxyModel {
                            sourceModel: main.model
                            currentPage: index
                            pageSize: main.pageSize
                        }
                        delegate: main.delegate
                    }
                }
            }
        }
    }


    Item {
        visible: main.model && Math.ceil(main.model.count/main.pageSize) > 1
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: Math.max( 16, appsView.height - Math.floor(appsView.height/delegateHeight)*delegateHeight)
        Row {
            id: dotsRow
            anchors.centerIn: parent
            spacing: 20

            Repeater {
                model: main.model?Math.ceil(main.model.count/main.pageSize):0


                Rectangle {
                    width: 6
                    height: 6
                    scale: appsView.currentIndex == index ? 1.5 : 1
                    radius: 5
                    smooth: true
                    opacity: appsView.currentIndex == index ? 0.8: 0.4
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
                            //animate only if near
                            if (Math.abs(appsView.currentIndex - index) > 1) {
                                appsView.positionViewAtIndex(index, ListView.Beginning)
                            } else {
                                appsView.currentIndex = index
                            }
                        }
                    }
                }
            }
        }
    }
}
