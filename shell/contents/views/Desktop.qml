/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2012 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 2.6
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.shell 2.0 as Shell
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace
import org.kde.kquickcontrolsaddons 2.0
import org.kde.activities 0.1 as Activities
import "../components"

Item {
    id: root
    width: 0
    height: 0

    property Item containment;
    property Item containmentNextActivityPreview;
    property Item wallpaper;
    property int notificationId: 0;
    property int buttonHeight: width/4
    property bool loadCompleted: false

    SmoothedAnimation {
        id: switchAnim
        target: activitiesView
        properties: "contentX"
        to: 0
        //it's a long travel, we want a consistent velocity rather than duration
        velocity: width
        easing.type: Easing.InOutQuad
    }
    Flickable {
        id: activitiesView
        z: 99
        visible: root.containment
        interactive: true
        anchors.fill: parent
        contentWidth: activitiesLayout.width
        contentHeight: height
        boundsBehavior: Flickable.StopAtBounds 
        maximumFlickVelocity: width/5
        property int currentIndex: -1

        onCurrentIndexChanged: {
            if (!activitiesLayout.loadCompleted) {
                contentX = currentIndex * width;
                return;
            }
            switchAnim.from = contentX;
            switchAnim.to = currentIndex * width;
            switchAnim.running = true;
        }
        onFlickEnded: movementEnded();
        onMovementEnded: {
            currentIndex = Math.round(contentX / width);
            //be sure the animation will work
            currentIndexChanged();
        }
        //don't animate
        onWidthChanged: contentX = currentIndex * width;

        Row {
            id: activitiesLayout
            height: activitiesView.height
            spacing: 0
            //don't try to do anything until we are well setted up
            property bool loadCompleted: root.loadCompleted && width == activitiesView.width * (activitiesLayout.children.length - 1) && activitiesLayout.children.length == activityRepeater.count + 1
            onLoadCompletedChanged: activitiesView.currentIndexChanged();

            Repeater {
                id: activityRepeater
                model: Activities.ActivityModel {
                    id: activityModel
                }

                delegate: Rectangle {
                    radius: 100
                    id: mainDelegate
                    width: activitiesView.width
                    height: activitiesView.height
                    property Item containment
                    readonly property bool inViewport: activitiesLayout.loadCompleted && root.containment &&
                            ((x >= activitiesView.contentX &&
                            x < activitiesView.contentX + activitiesView.width) ||
                            (x + width > activitiesView.contentX &&
                            x + width < activitiesView.contentX + activitiesView.width))
                    readonly property bool currentActivity: root.containment && model.current

                    
                    Connections {
                        target: activitiesView
                        onMovementEnded: {
                            if (activitiesView.currentIndex == index) {
                                activityModel.setCurrentActivity(model.id, function(){
                                    mainDelegate.containment.parent = mainDelegate;
                                });
                            }
                        }
                        onFlickEnded: activitiesView.movementEnded()
                    }
                    onInViewportChanged: {
                        if (inViewport && !mainDelegate.containment) {
                            mainDelegate.containment = desktop.containmentItemForActivity(model.id);
                            containmentNextActivityPreview = containment;
                            mainDelegate.containment.parent = mainDelegate;
                            mainDelegate.containment.anchors.fill = mainDelegate;
                        }
                    }
                    onCurrentActivityChanged: {
                        if (currentActivity) {
                            activitiesView.currentIndex = index;
                        }
                    }
                    
                    Text {
                        z: 100
                        text: "inViewport: " + mainDelegate.inViewport +
                            "\n activitiesView.contentX: " + activitiesView.contentX +
                            "\n mainDelegate.x: "+ mainDelegate.x +
                            "\n (activitiesView.contentX + activitiesView.width):"+ (activitiesView.contentX + activitiesView.width) +
                            "\n (mainDelegate.x + mainDelegate.width):" + (mainDelegate.x + mainDelegate.width)
                    }
                }
            }
        }
    }

    //TODO: adjust its Y to current containment availablescreenrect
    PageIndicator {
        z: 100
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        count: activitiesView.count
        currentIndex: activitiesView.currentIndex
    }


    function toggleWidgetExplorer(containment) {
        console.log("Widget Explorer toggled");
        if (widgetExplorerStack.source != "") {
            widgetExplorerStack.source = "";
        } else {
            widgetExplorerStack.setSource(Qt.resolvedUrl("../explorer/WidgetExplorer.qml"), {"containment": containment})
        }
    }

    Loader {
        id: widgetExplorerStack
        z: 99
        asynchronous: true
        y: containment ? containment.availableScreenRect.y : 0
        height: containment ? containment.availableScreenRect.height : parent.height
        width: parent.width
        
        onLoaded: {
            if (widgetExplorerStack.item) {
                item.closed.connect(function() {
                    widgetExplorerStack.source = ""
                });
            }
        }
    }

    Binding {
        target: containment
        property: "width"
        value: root.width
    }
    //some properties that shouldn't be accessible from elsewhere
    QtObject {
        id: internal;

        property Item oldContainment: null;
        property Item newContainment: null;
    }

    //pass the focus to the containment, so it can react to homescreen activate/inactivate
    Connections {
        target: desktop
        onActiveChanged: {
            containment.focus = desktop.active;
        }
    }

    Loader {
        id: pinOverlay
        anchors {
            fill: parent
            topMargin: containment.availableScreenRect.y
            bottomMargin: parent.height - containment.availableScreenRect.height - containment.availableScreenRect.y
        }
        z: 222
        source: Qt.resolvedUrl("Pin.qml")
    }

    onWidthChanged: {
        //There will be a resize at the very start which we can't avoid, don't do anything until then
        //configure the view behavior
        if (desktop && root.width > 0) {
            desktop.width = width;
            desktop.height = height;
            root.loadCompleted = true;
        }
    }
    Component.onCompleted: {
        //configure the view behavior
        if (desktop && root.width > 0) {
            desktop.width = width;
            desktop.height = height;
            root.loadCompleted = true;
        }
    }
}
