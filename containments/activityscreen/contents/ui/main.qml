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
 *   GNU Library General Public License for more details
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
import org.kde.datamodels 0.1 as DataModels

import "plasmapackage:/code/LayoutManager.js" as LayoutManager

Item {
    id: main
    width: 540
    height: 540


    property Item currentGroup
    property int currentIndex: -1

    property Item addResource

    property variant availScreenRect: plasmoid.availableScreenRegion(plasmoid.screen)[0]

    Component.onCompleted: {
        plasmoid.containmentType = "CustomContainment"
        plasmoid.appletAdded.connect(addApplet)
        LayoutManager.restore()
        for (var i = 0; i < plasmoid.applets.length; ++i) {
            var applet = plasmoid.applets[i]
            addApplet(applet, 0)
        }
    }

    function addApplet(applet, pos)
    {
        var component = Qt.createComponent("PlasmoidGroup.qml")
        var plasmoidGroup = component.createObject(resultsFlow)
        plasmoidGroup.width = LayoutManager.cellSize.width*2
        plasmoidGroup.height = LayoutManager.cellSize.height*2
        plasmoidGroup.applet = applet
        plasmoidGroup.category = "Applet-"+applet.id
        LayoutManager.itemGroups[plasmoidGroup.category] = plasmoidGroup
    }

    function showAddResource()
    {
        var component = Qt.createComponent("AddResource.qml");
        main.addResource = component.createObject(main);
        print(component.errorString())
        addResource.show()
    }

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

    DataModels.MetadataCloudModel {
        id: categoryListModel
        cloudCategory: "rdf:type"
        activityId: plasmoid.activityId
        allowedCategories: userTypes.userTypes
        onCategoriesChanged: {
            categoriesTimer.restart()
        }
    }

    DataModels.MetadataUserTypes {
        id: userTypes
    }

    MobileComponents.ResourceInstance {
        id: resourceInstance
    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.Svg {
        id: configIconsSvg
        imagePath: "widgets/configuration-icons"
    }

    Timer {
        id: scrollTimer
        running: false
        interval: 40
        repeat: true
        property bool backwards
        property Item draggingItem
        onTriggered: {
            if (backwards) {
                if (mainFlickable.contentY > 0) {
                    mainFlickable.contentY -= 10
                    draggingItem.y -= 10
                }
            } else {
                mainFlickable.contentY += 10
                draggingItem.y += 10
            }
        }
    }

    ScrollBar {
        scrollArea: mainFlickable
        width: 8
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
    }

    Flickable {
        id: mainFlickable
        anchors.fill: main
        interactive: contentItem.height>mainFlickable.height
        PropertyAnimation {
            id: contentScrollTo0Animation
            target: mainFlickable
            properties: "contentY"
            to: 0
            duration: 250
            running: false
        }

        contentWidth: contentItem.width
        contentHeight: contentItem.height

        MouseArea {
            id: contentItem
            width: mainFlickable.width
            height: childrenRect.y+childrenRect.height+availScreenRect.y+20

            onClicked: {
                resourceInstance.uri = ""
                main.currentIndex = -1
            }


            Connections {
                target: plasmoid
                onActivityNameChanged: titleText.text = plasmoid.activityName
            }

            Row {
                id: toolBar
                spacing: 16
                anchors {
                    top: parent.top
                    left: parent.left
                    topMargin: availScreenRect.y+20
                    leftMargin: 72
                }

                MobileComponents.ActionButton {
                    svg: iconsSvg
                    elementId: "add"
                    onClicked: {
                        showAddResource()
                    }
                    //text: i18n("Add item")
                }

                MobileComponents.ActionButton {
                    id: configureButton
                    svg: iconsSvg
                    elementId: "configure"
                    action: plasmoid.action("configure")
                    //text: i18n("Configure")
                    //FIXME: WHY?
                    Component.onCompleted: {
                        action.enabled = true
                    }
                }

                MobileComponents.TextEffects {
                    id: titleText
                    text: (String(plasmoid.activityName).length <= 28) ? plasmoid.activityName:String(plasmoid.activityName).substr(0,28) + "..."
                    color: "white"
                    horizontalOffset: 1
                    verticalOffset: 1
                    bold: true
                    pixelSize: 20
                    anchors.verticalCenter: configureButton.verticalCenter
                }
            }

            Timer {
                id: categoriesTimer
                repeat: false
                running: false
                interval: 0
                onTriggered: {
                    var component = Qt.createComponent("ItemsListGroup.qml")
                    var existingCategories = Array()

                    //FIXME: find a more efficient way
                    //destroy removed categories
                    for (var category in LayoutManager.itemGroups) {
                        if (category.indexOf("Applet-") != 0 &&
                            categoryListModel.categories.indexOf(category) == -1) {
                            var item = LayoutManager.itemGroups[category]
                            LayoutManager.setSpaceAvailable(item.x, item.y, item.width, item.height, true)
                            item.destroy()
                            delete LayoutManager.itemGroups[category]
                            //debugFlow.refresh();
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

            //FIXME: debug purposes only, remove asap
            /*Flow {
                id: debugFlow
                anchors.fill: resultsFlow
                visible: true
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
            }*/

            Item {
                id: resultsFlow
                //height: Math.min(300, childrenRect.height)
                width: Math.round((parent.width-64)/LayoutManager.cellSize.width)*LayoutManager.cellSize.width
                height: childrenRect.y+childrenRect.height
                z: 900

                anchors {
                    top: toolBar.bottom
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }


                //This is just for event compression when a lot of boxes are created one after the other
                Timer {
                    id: layoutTimer
                    repeat: false
                    running: false
                    interval: 100
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
                            //debugFlow.refresh();
                        }
                        LayoutManager.save()
                    }
                }
                Component.onCompleted: {
                    LayoutManager.resultsFlow = resultsFlow
                }
            }
            Item {
                anchors.fill: resultsFlow
                z: 0
                Item {
                    id: placeHolder
                    property bool animationsEnabled
                    width: 100
                    height: 100
                    property int minimumWidth
                    property int minimumHeight
                    property Item syncItem
                    function syncWithItem(item)
                    {
                        syncItem = item
                        minimumWidth = item.minimumWidth
                        minimumHeight = item.minimumHeight
                        repositionTimer.running = true
                        if (placeHolderPaint.opacity < 1) {
                            placeHolder.delayedSyncWithItem()
                        }
                    }
                    function delayedSyncWithItem()
                    {
                        placeHolder.x = placeHolder.syncItem.x
                        placeHolder.y = placeHolder.syncItem.y
                        placeHolder.width = placeHolder.syncItem.width
                        placeHolder.height = placeHolder.syncItem.height
                        //only positionItem here, we don't want to save
                        LayoutManager.positionItem(placeHolder)
                        LayoutManager.setSpaceAvailable(placeHolder.x, placeHolder.y, placeHolder.width, placeHolder.height, true)
                    }
                    Timer {
                        id: repositionTimer
                        interval: 200
                        repeat: false
                        running: false
                        onTriggered: {
                            placeHolder.delayedSyncWithItem()
                        }
                    }
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
                        enabled: placeHolderPaint.opacity == 1
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on y {
                        enabled: placeHolderPaint.opacity == 1
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on width {
                        enabled: placeHolderPaint.opacity == 1
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }

    SlcComponents.SlcMenu {
        id: contextMenu
    }
}
