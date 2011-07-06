// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.plasma.slccomponents 0.1 as SlcComponents

import "plasmapackage:/code/LayoutManager.js" as LayoutManager

Item {
    id: main
    width: 540
    height: 540

    property alias urls: metadataSource.connectedSources

    property Item currentGroup
    property int currentIndex: -1

    Component.onCompleted: {
        LayoutManager.restore()

        //FIXME: why it arrives as a string?
        if (plasmoid.readConfig("FirstStartup") == true) {
            addResource.show()
        }
    }

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

    PlasmaCore.DataSource {
        id: metadataSource
        engine: "org.kde.active.metadata"
        interval: 0

        onSourceAdded: {
            //console.log("source added:" + source);
            //connectSource(source);
        }

        onDataChanged: {
            plasmoid.busy = false
        }
        Component.onCompleted: {
            //connectedSources = sources;
            //connectedSources = [ "wall" ]
        }

    }

    MobileComponents.ResourceInstance {
        id: resourceInstance
    }

    PlasmaCore.Theme {
        id: theme
    }

    Item {
        property variant availScreenRect: plasmoid.availableScreenRegion(plasmoid.screen)[0]


        anchors.fill: parent
        anchors.leftMargin: availScreenRect.x
        anchors.topMargin: availScreenRect.y
        anchors.rightMargin: parent.width - availScreenRect.width - availScreenRect.x
        anchors.bottomMargin: parent.height - availScreenRect.height - availScreenRect.y


        Text {
            id: titleText
            anchors.top: toolRow.top
            anchors.left: parent.left
            anchors.leftMargin: 72
            text: plasmoid.activityName
            font.bold: true
            style: Text.Outline
            styleColor: Qt.rgba(1, 1, 1, 0.6)
            font.pixelSize: 25
        }
        Connections {
            target: plasmoid
            onActivityNameChanged: titleText.text = plasmoid.activityName
        }


        Row {
            id: toolRow
            spacing: 8
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 12
                rightMargin: 22
            }

            MobileComponents.ActionButton {
                svg: iconsSvg
                elementId: "add"
                onClicked: {
                    addResource.show()
                }
                text: i18n("Add item")
            }

            MobileComponents.ActionButton {
                svg: iconsSvg
                elementId: "configure"
                action: plasmoid.action("configure")
                text: i18n("Configure")
                //FIXME: WHY?
                Component.onCompleted: {
                    action.enabled = true
                }
            }
        }

        PlasmaCore.DataModel {
            id: metadataModel
            keyRoleFilter: ".*"
            dataSource: metadataSource
        }

        Timer {
            id: categoriesTimer
            repeat: false
            running: false
            interval: 2000
            onTriggered: {
                var component = Qt.createComponent("ItemGroup.qml")
                var existingCategories = Array()

                //FIXME: find a more efficient way
                //destroy removed categories
                for (var category in LayoutManager.itemGroups) {
                    if (categoryListModel.categories.indexOf(category) == -1) {
                        var item = LayoutManager.itemGroups[category]
                        LayoutManager.setSpaceAvailable(item.x, item.y, item.width, item.height, true)
                        item.destroy()
                        delete LayoutManager.itemGroups[category]
                        debugFlow.refresh();
                    }
                }

                //add newly created categories
                for (var i = 0; i < categoryListModel.categories.length; ++i) {
                    var category = categoryListModel.categories[i]
                    if (!LayoutManager.itemGroups[category]) {
                        var itemGroup = component.createObject(resultsFlow)
                        itemGroup.category = category
                        LayoutManager.itemGroups[category] = itemGroup
                    }
                    existingCategories[existingCategories.length] = category
                }
            }
        }

        MobileComponents.CategorizedProxyModel {
            id: categoryListModel
            sourceModel: metadataModel
            categoryRole: "genericClassName"
            onCategoriesChanged: {
                categoriesTimer.restart()
            }
        }

        //FIXME: debug purposes only, remove asap
        Flow {
            id: debugFlow
            anchors.fill: resultsFlow
            visible: false
            Repeater {
                model: 60
                Rectangle {
                    width: LayoutManager.cellSize.width
                    height: LayoutManager.cellSize.height
                }
            }
            function refresh()
            {
                for (var i=0; i<debugFlow.children.length; ++i) {
                    child = debugFlow.children[i]
                    child.opacity = LayoutManager.availableSpace(child.x,child.y, LayoutManager.cellSize.width, LayoutManager.cellSize.height).width>0?0.8:0.3
                }
            }
        }

        Item {
            id: resultsFlow
            //height: Math.min(300, childrenRect.height)
            width: Math.round((parent.width-64)/LayoutManager.cellSize.width)*LayoutManager.cellSize.width

            anchors {
                top: toolRow.bottom
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }


            Timer {
                id: layoutTimer
                repeat: false
                running: false
                interval: 2000
                onTriggered: {
                    LayoutManager.resetPositions()
                    for (var i=0; i<resultsFlow.children.length; ++i) {
                        child = resultsFlow.children[i]
                        if (LayoutManager.itemsConfig[child.category]) {
                            var rect = LayoutManager.itemsConfig[child.category]
                            child.x = rect.x
                            child.y = rect.y
                            child.width = rect.width
                            child.height = rect.height
                        } else {
                            child.x = 0
                            child.y = 0
                            child.width = Math.min(470, 32+child.categoryCount*140)
                        }

                        child.visible = true
                        LayoutManager.positionItem(child)
                        child.enabled = true
                        debugFlow.refresh();
                    }
                }
            }
            Component.onCompleted: {
                LayoutManager.resultsFlow = resultsFlow
            }
        }
        Item {
            anchors.fill: resultsFlow
            Item {
                id: placeHolder
                property bool animationsEnabled
                width: 100
                height: 100
            }
            Rectangle {
                id: placeHolderPaint
                x: placeHolder.x
                y: placeHolder.y
                width: placeHolder.width
                height: placeHolder.height
                z: 0
                opacity: 0
                radius: 8
                smooth: true
                color: Qt.rgba(1,1,1,0.3)
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on x {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on y {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    AddResource {
        id: addResource
        anchors.fill: parent
    }

    Timer {
       id: queryTimer
       running: true
       repeat: false
       interval: 1000
       onTriggered: {
            LayoutManager.resetPositions()
            plasmoid.busy = false
            metadataSource.connectedSources = ["CurrentActivityResources:"+plasmoid.activityId]
       }
    }

    SlcComponents.SlcMenu {
        id: contextMenu
    }
}
