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

MouseArea {
    id: root
    width: 1080
    height: 1920

    property Item containment;
    property Item containmentNextActivityPreview;
    property Item wallpaper;
    property int notificationId: 0;
    property int buttonHeight: width/4
    property bool containmentsEnterFromRight: true
    drag.filterChildren: false

    //HACK FIXME this timer hack is to wait activitiesView finished all its setup
    //which we can't know for sure and suggests that we can't really use it
    Timer {
        id: hackTimer
        interval: 1000
        running: true
    }
    ListView {
        id: activitiesView
        z: 998
        visible: root.containment
        interactive: true
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds 
        highlightMoveDuration: 0
        highlightRangeMode: ListView.StrictlyEnforceRange
        cacheBuffer: width * count * 2
        model: Activities.ActivityModel {
            id: activityModel
        }

        delegate: Rectangle {
            radius: 100
            id: mainDelegate
            width: activitiesView.width
            height: activitiesView.height
            property Item containment
            readonly property bool inViewport: !hackTimer.running && root.containment &&
                     ((x >= activitiesView.contentX &&
                       x < activitiesView.contentX + activitiesView.width) ||
                      (x + width > activitiesView.contentX &&
                       x + width < activitiesView.contentX + activitiesView.width))
            readonly property bool currentActivity: root.containment && model.current

            
            Connections {
                target: activitiesView
                onMovementEnded: {return;
                    if (activitiesView.currentIndex == index) {
                        activityModel.setCurrentActivity(model.id, function(){
                            mainDelegate.containment.parent = mainDelegate;
                        });
                    }
                }
                onFlickEnded: onMovementEnded()
            }
            onInViewportChanged: {
                if (inViewport && !mainDelegate.containment) {
                    mainDelegate.containment = desktop.containmentItemForActivity(model.id);
                    print(mainDelegate.containment+" "+root.containment);
                    containmentNextActivityPreview = containment;
                    mainDelegate.containment.parent = mainDelegate;
                    mainDelegate.containment.anchors.fill = mainDelegate;
                }
            }
            onCurrentActivityChanged: {
                if (currentActivity) {
                    activitiesView.positionViewAtIndex(index, ListView.Beginning);
                    activitiesView.currentIndex = index;
                }
            }
            
            Text {
                z: 100
                text: mainDelegate.inViewport + " " + activitiesView.contentX +" "+ mainDelegate.x +" "+ (activitiesView.contentX + activitiesView.width) + " " + (mainDelegate.x + mainDelegate.width)
            }
        }
    }
    PageIndicator {
        z: 999
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        count: activitiesView.count
        currentIndex: activitiesView.currentIndex
    }
 /*   property int startX
    onPressed: {
        startX = mouse.x - containment.x 
    }
    onPositionChanged: {
        containment.x = mouse.x - startX
        if (containment.x < 0) {
            var cont = desktop.containmentItemForActivity("395250d4-d44b-4735-8494-4db49beb29dd");
            if (cont != containmentNextActivityPreview) {
                print(cont+" "+root.containment);
                containmentNextActivityPreview = cont;
                cont.width = root.width;
                cont.height = root.height;
                cont.parent = root;
            }
            containmentNextActivityPreview.x = containment.x + containment.width;
        }
    }
    onReleased: {
        activityModel.setCurrentActivity("395250d4-d44b-4735-8494-4db49beb29dd", function(){});
    }*/
    ActivityHandle {
        mirrored: true
    }
    ActivityHandle {
        mirrored: false
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
/*
    onContainmentChanged: {
        if (containment == null) {
            return;
        }

        if (switchAnim.running) {
            //If the animation was still running, stop it and reset
            //everything so that a consistent state can be kept
            switchAnim.running = false;
            internal.newContainment.visible = false;
            internal.oldContainment.visible = false;
            internal.oldContainment = null;
        }

        internal.newContainment = containment;
        containment.visible = true;

        if (internal.oldContainment != null && internal.oldContainment != containment) {
            switchAnim.running = true;
        } else {
            //containment.anchors.left = root.left;
            containment.anchors.top = root.top;
            //containment.anchors.right = root.right;
            containment.anchors.bottom = root.bottom;
            if (internal.oldContainment) {
                internal.oldContainment.visible = false;
            }
            internal.oldContainment = containment;
        }
    }
*/
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
/*
    SequentialAnimation {
        id: switchAnim
        ScriptAction {
            script: {
                if (containment) {
                    //containment.z = 1;
                    //containment.x = root.containmentsEnterFromRight ? root.width : -root.width;
                }
                if (internal.oldContainment) {
                    //internal.oldContainment.z = 0;
                    //internal.oldContainment.x = 0;
                }
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: internal.oldContainment
                properties: "x"
                to: internal.newContainment != null ? (root.containmentsEnterFromRight ? -root.width : root.width) : 0
                duration: 400
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: internal.newContainment
                properties: "x"
                to: 0
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        ScriptAction {
            script: {
                if (internal.oldContainment) {
                    internal.oldContainment.visible = false;
                }
                if (containment) {
                    containment.anchors.top = root.top;
                    containment.anchors.bottom = root.bottom;
                    internal.oldContainment = containment;
                }
            }
        }
    }
*/
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

    Component.onCompleted: {
        //configure the view behavior
        if (desktop) {
            desktop.width = width;
            desktop.height = height;
        }
    }
}
