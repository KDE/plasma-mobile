// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *   Copyright 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
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

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.activities 0.1 as Activities

import "LayoutManager.js" as LayoutManager

Item {
    id: main
    width: 540
    height: 540


    property Item currentGroup
    property int currentIndex: -1

    property Item addResource
    property variant availScreenRect: plasmoid.availableScreenRect

    property int iconWidth: theme.mSize(theme.defaultFont).width * 14
    property int iconHeight: theme.mSize(theme.defaultFont).width * 14
    onIconHeightChanged: updateGridSize()

    function updateGridSize()
    {
        LayoutManager.cellSize.width = main.iconWidth + borderSvg.elementSize("left").width + borderSvg.elementSize("right").width
        LayoutManager.cellSize.height = main.iconHeight + theme.mSize(theme.defaultFont).height + borderSvg.elementSize("top").height + borderSvg.elementSize("bottom").height + draggerSvg.elementSize("root-top").height + draggerSvg.elementSize("root-bottom").height
        layoutTimer.restart()
    }

    Component.onCompleted: {
        //do it here since theme is not accessible in LayoutManager
        //TODO: icon size from the configuration
        //TODO: remove hardcoded sizes, use framesvg boders
        if (width >= height) {
            LayoutManager.orientation = "horizontal"
        } else {
            LayoutManager.orientation = "vertical"
        }

        updateGridSize()
        LayoutManager.plasmoid = plasmoid
        //plasmoid.containmentType = "CustomContainment"
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
        applet.parent = plasmoidGroup.appletContainment
        applet.anchors.fill = plasmoidGroup.appletContainment
        applet.visible = true
        plasmoidGroup.category = "Applet-"+applet.id
        LayoutManager.itemGroups[plasmoidGroup.category] = plasmoidGroup
    }

    onWidthChanged: layoutTimer.restart()
    onHeightChanged: layoutTimer.restart()

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

    //those two are used only for sizes, not painted ever
    //FIXME: way to avoid instantiating them?
    PlasmaCore.Svg {
        id: borderSvg
        imagePath: "widgets/background"
    }
    PlasmaCore.Svg {
        id: draggerSvg
        imagePath: "widgets/extender-dragger"
    }


    PlasmaCore.SortFilterModel {
        id: categoryListModel
        sourceModel: Activities.ResourceModel {
            id: resourceModel
            shownAgents: ":any"
            shownActivities: ":current"
        }

        onCountChanged: {
            categoriesTimer.restart()
        }
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

    PlasmaComponents.ScrollBar {
        flickableItem: mainFlickable
        orientation: Qt.Vertical
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
    }

    Flickable {
        id: mainFlickable
        anchors {
            fill: main
            leftMargin: availScreenRect.x
            rightMargin: parent.width - availScreenRect.x - availScreenRect.width
        }
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
            height: childrenRect.y+childrenRect.height

            onClicked: {
                main.currentIndex = -1
            }


            Connections {
                target: plasmoid
                onActivityNameChanged: titleText.text = plasmoid.activityName
                onScreenChanged: {
                    if (plasmoid.screen < 0) {
                        resourceInstance.uri = ""
                        main.currentIndex = -1
                    }
                }

                onAppletRemoved: {
                    LayoutManager.removeApplet(applet)
                    LayoutManager.save()
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

                    var categories = new Array()
                    //build category list
                    for (var i = 0; i < categoryListModel.count; ++i) {
                        categories[i] = categoryListModel.get(i).agent
                    }

                    //FIXME: find a more efficient way
                    //destroy removed categories
                    for (var category in LayoutManager.itemGroups) {
                        if (category.indexOf("Applet-") != 0 &&
                            categories.indexOf(category) == -1) {
                            var item = LayoutManager.itemGroups[category]
                            LayoutManager.setSpaceAvailable(item.x, item.y, item.width, item.height, true)
                            item.destroy()
                            delete LayoutManager.itemGroups[category]
                            //debugFlow.refresh();
                        }
                    }

                    //add newly created categories
                    for (var i = 0; i < categories.length; ++i) {
                        var category = categories[i]
                        if (!LayoutManager.itemGroups[category]) {
                            var itemGroup = component.createObject(resultsFlow)
                            var e = component.errorString();
                            if (e != "") {
                                print("Error loading ItemsList.qml: " + component.errorString());
                            }
                            itemGroup.category = category
                            LayoutManager.itemGroups[category] = itemGroup
                        }
                        existingCategories[existingCategories.length] = category
                        layoutTimer.restart()
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
                width: Math.floor(parent.width/LayoutManager.cellSize.width)*LayoutManager.cellSize.width
                height: childrenRect.y+childrenRect.height
                z: 900
                anchors {
                    top: parent.top
                    topMargin: units.gridUnit * 10 // make sure that our plasmoids will not cover the toolbox
                    horizontalCenter: parent.horizontalCenter
                }

                //This is just for event compression when a lot of boxes are created one after the other
                Timer {
                    id: layoutTimer
                    repeat: false
                    running: false
                    interval: 100
                    onTriggered: {

                        //check if the orientation is still the same
                        var newOrientation
                        //horizontal
                        if (width >= height) {
                            newOrientation = "horizontal"
                        //vertical
                        } else {
                            newOrientation = "vertical"
                        }
                        if (LayoutManager.orientation != newOrientation) {
                            LayoutManager.orientation = newOrientation
                            LayoutManager.resetPositions()
                            LayoutManager.restore()
                        }

                        LayoutManager.resetPositions()
                        for (var i=0; i<resultsFlow.children.length; ++i) {
                            var child = resultsFlow.children[i]
                            if (child.enabled) {
                                if (LayoutManager.itemsConfig(child.category)) {
                                    var rect = LayoutManager.itemsConfig(child.category)
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
                            } else {
                                child.visible = false
                            }
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
}
