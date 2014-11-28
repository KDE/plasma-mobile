/*
 *   Copyright 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
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

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQml.Models 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import "WindowManagement.js" as WindowManagement

Rectangle {
    property alias showSplash: splash.visible
    property bool showPanel: true
    readonly property alias layers: layers
    readonly property real topBarHeight: units.iconSizes.small
    readonly property real bottomBarHeight: units.iconSizes.medium
    property var currentWindow: null

    onCurrentWindowChanged: {
        if (!currentWindow) {
            return;
        }
        compositorRoot.state = "application";
    }

    id: compositorRoot
    color: "black"
    state: "homeScreen"

    Image {
        id: splash
        anchors.fill: parent
        source: "klogo.png"
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit
        z: 1000
    }

    ListModel {
        id: surfaceModel
    }

    Connections {
        target: compositor
        onSurfaceMapped: WindowManagement.surfaceMapped(surface)
        onSurfaceUnmapped: WindowManagement.surfaceUnmapped(surface)
        onSurfaceDestroyed: WindowManagement.surfaceDestroyed(surface)
    }

    QtObject {
        readonly property alias desktop: desktopLayer
        readonly property alias windows: windowsLayer
        readonly property alias panel: panelLayer

        id: layers
    }

    Item {
        id: desktopLayer
        anchors.fill: parent
        visible: true
    }

    Rectangle {
        id: windowsLayerBackground
        anchors.fill: parent
        anchors.topMargin: topBarHeight
        color: Qt.rgba(0, 0, 0, 0.5)

        Flickable {
            id: windowsLayer
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            height: windowsLayout.height
            interactive: windowsLayer.switchMode
            contentWidth: windowsLayout.width * windowsLayout.scale
            contentHeight: windowsLayout.height

            property bool switchMode: windowsLayout.scale < 1
            function addWindow (window) {
                window.parent = windowsLayout
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    compositorRoot.state = "homeScreen";
                }
                Row {
                    id: windowsLayout
                    height: windowsLayerBackground.height
                    transformOrigin: Item.Left
                    onChildrenChanged: {
                        if (children.length == 0) {
                            compositorRoot.state = "homeScreen";
                        }
                    }
                }
            }
        }
    }

    Item {
        id: panelLayer
        anchors.fill: parent
        visible: showPanel
        z: 3
    }

    Rectangle {
        id: bottomBar
        z: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: (!windowsLayer.switchMode) ? 0 : bottomBarHeight
        color: Qt.rgba(0, 0, 0, 0.5)

        Behavior on height {
            NumberAnimation {
                easing.type: "InOutQuad"
                duration: units.shortDuration
            }
        }

        RowLayout {
            anchors.fill: parent

            PlasmaCore.IconItem {
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                width: units.iconSizes.smallMedium
                height: width
                source: "go-home"

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: units.iconSizes.medium
                Layout.preferredHeight: units.iconSizes.medium

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        compositorRoot.state = "homeScreen";
                    }
                }
            }
        }
    }

    MouseArea {
        id: taskSwitchEdge
        z: 1000
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 8
        enabled: windowsLayout.children.length > 0
        property int oldX: 0
        onPressed: {
            oldX = mouse.x;
        }
        onPositionChanged: {
            compositorRoot.state = "switcher";
            var newScale = (1-Math.abs(mouse.y)/(compositorRoot.height/2))
            if (newScale > 0.3) {
                windowsLayout.scale = newScale
            }
            windowsLayer.contentX -= (mouse.x - oldX);
            oldX = mouse.x;
        }
        onReleased: {
            if (windowsLayout.scale > 0.7) {
                compositorRoot.state = compositorRoot.currentWindow ? "application" : "homeScreen";
            }
        }
    }

    states: [
        State {
            name: "homeScreen"
            PropertyChanges {
                target: windowsLayerBackground
                opacity: 0
            }
            PropertyChanges {
                target: windowsLayout
                scale: 1
            }
        },
        State {
            name: "application"
            PropertyChanges {
                target: windowsLayerBackground
                opacity: 1
            }
            PropertyChanges {
                target: windowsLayout
                scale: 1
            }
            PropertyChanges {
                target: windowsLayer
                contentX: compositorRoot.currentWindow ? compositorRoot.currentWindow.x : 0
            }
        },
        State {
            name: "switcher"
            PropertyChanges {
                target: windowsLayerBackground
                opacity: 1
            }
            PropertyChanges {
                target: windowsLayer
                contentX: compositorRoot.currentWindow ? compositorRoot.currentWindow.x : 0
            }
        }
    ]

    transitions: [
        Transition {
            to: "switcher"
            SequentialAnimation {
                ScriptAction {
                    script: {
                        desktopLayer.z = 1
                        windowsLayerBackground.z = 2
                    }
                }
                PropertyAnimation {
                    target: windowsLayerBackground
                    duration: units.longDuration
                    easing: Easing.InOutQuad
                    properties: "opacity"
                }
            }
        },
        Transition {
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        target: windowsLayerBackground
                        duration: units.longDuration
                        easing: Easing.InOutQuad
                        properties: "opacity"
                    }
                    PropertyAnimation {
                        target: windowsLayout
                        duration: units.shortDuration
                        easing: Easing.InOutQuad
                        properties: "scale"
                    }
                    PropertyAnimation {
                        target: windowsLayer
                        duration: units.shortDuration
                        easing: Easing.InOutQuad
                        properties: "contentX"
                    }
                }
                ScriptAction {
                    script: {
                        if (compositorRoot.state == "homeScreen") {
                            desktopLayer.z = 2;
                            windowsLayerBackground.z = 1;
                            compositorRoot.currentWindow = null;
                        } else {
                            desktopLayer.z = 1;
                            windowsLayerBackground.z = 2;
                        }
                    }
                }
            }
        }
    ]
}
