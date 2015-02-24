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
    property alias showKeyboard: keyboardLayer.visible
    readonly property alias layers: layers
    readonly property real topBarHeight: units.iconSizes.small
    readonly property real bottomBarHeight: units.iconSizes.medium
    property var currentWindow: null
    property var shellWindow: null;

    onCurrentWindowChanged: {
        if (!currentWindow) {
            compositorRoot.state = "homeScreen";
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
        readonly property alias windows: windowsLayerBackground
        readonly property alias panel: panelLayer
        readonly property alias keyboard: keyboardLayer

        id: layers
    }

    Item {
        id: desktopLayer
        anchors.fill: parent
        visible: true
    }

    Rectangle {
        id: windowsLayerBackground
        anchors {
            fill: parent
            topMargin: topBarHeight
            bottomMargin: bottomBarHeight
        }
        color: Qt.rgba(0, 0, 0, 0.9)
        function addWindow (window) {
            window.parent = windowsLayout
        }
        property bool switchMode: windowsZoom.scale < 1

        Item {
            id: windowsZoom
            anchors.fill: parent
            Flickable {
                id: windowsLayer
                anchors.centerIn: parent

                flickableDirection: Flickable.HorizontalFlick
                height: windowsZoom.height * 2
                width: windowsZoom.width * 2
                interactive: windowsLayerBackground.switchMode
                contentWidth: windowsLayout.width
                contentHeight: windowsLayout.height

                MouseArea {
                    height: windowsLayer.height
                    width: windowsLayout.width
                    onClicked: {
                        compositorRoot.state = "homeScreen";
                    }
                    Row {
                        id: windowsLayout
                        anchors.centerIn: parent
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
    }

    Item {
        id: panelLayer
        anchors.fill: parent
        visible: showPanel
        z: 3
    }

    Item {
        id: keyboardLayer
        anchors.fill: parent
        z: 800
        onVisibleChanged: {
            if (!visible && compositorRoot.shellWindow) {
                compositorRoot.shellWindow.child.takeFocus();
            }
        }
    }

    Rectangle {
        id: bottomBar
        z: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: bottomBarHeight
        color: Qt.rgba(0, 0, 0, 0.7)

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
                source: "distribute-horizontal-x"
                enabled: compositorRoot.state != "switcher";
                opacity: enabled ? 1 : 0.6

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: units.iconSizes.medium
                Layout.preferredHeight: units.iconSizes.medium

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        compositorRoot.state = "switcher";
                    }
                }
            }
            PlasmaCore.IconItem {
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                width: units.iconSizes.smallMedium
                height: width
                source: "go-home"
                enabled: compositorRoot.state != "homeScreen";
                opacity: enabled ? 1 : 0.6

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
            PlasmaCore.IconItem {
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                width: units.iconSizes.smallMedium
                height: width
                source: "window-close"
                enabled: compositorRoot.currentWindow
                opacity: enabled ? 1 : 0.6

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: units.iconSizes.medium
                Layout.preferredHeight: units.iconSizes.medium

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        compositorRoot.state = "homeScreen";
                        compositorRoot.currentWindow.close();
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
        enabled: windowsLayout.children.length > 0 && compositorRoot.state != "switcher"
        property int oldX: 0
        onPressed: {
            oldX = mouse.x;
        }
        onPositionChanged: {
            compositorRoot.state = "changing";
            compositorRoot.showKeyboard = false;

            var newScale = (1-Math.abs(mouse.y)/(compositorRoot.height/2))
            if (newScale > 0.3) {
                windowsZoom.scale = newScale
            }
            windowsLayer.contentX -= (mouse.x - oldX);
            oldX = mouse.x;
        }
        onReleased: {
            if (windowsZoom.scale > 0.7) {
                compositorRoot.state = compositorRoot.currentWindow ? "application" : "homeScreen";
            } else {
                compositorRoot.state = "switcher";
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
                target: windowsZoom
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
                target: windowsZoom
                scale: 1
            }
            PropertyChanges {
                target: windowsLayer
                contentX: compositorRoot.currentWindow ? compositorRoot.currentWindow.x - windowsLayerBackground.width/2 : 0
            }
        },
        State {
            name: "switcher"
            PropertyChanges {
                target: windowsLayerBackground
                opacity: 1
            }
            PropertyChanges {
                target: windowsZoom
                scale: 0.5
            }
            PropertyChanges {
                target: windowsLayer
                contentX: compositorRoot.currentWindow ? compositorRoot.currentWindow.x - windowsLayerBackground.width/2 : 0
            }
        },
        State {
            name: "changing"
            PropertyChanges {
                target: windowsLayerBackground
                opacity: 1
            }
            PropertyChanges {
                target: windowsLayer
                contentX: compositorRoot.currentWindow ? compositorRoot.currentWindow.x - windowsLayerBackground.width/2 : 0
            }
        }
    ]

    transitions: [
        Transition {
            to: "changing"
            SequentialAnimation {
                ScriptAction {
                    script: {
                        desktopLayer.z = 1
                        windowsLayerBackground.z = 800
                    }
                }
                PropertyAnimation {
                    target: windowsLayerBackground
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
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
                        easing.type: Easing.InOutQuad
                        properties: "opacity"
                    }
                    PropertyAnimation {
                        target: windowsZoom
                        duration: units.shortDuration
                        easing.type: Easing.InOutQuad
                        properties: "scale"
                    }
                    PropertyAnimation {
                        target: windowsLayer
                        duration: units.shortDuration
                        easing.type: Easing.InOutQuad
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
                            windowsLayerBackground.z = 800;
                            if (compositorRoot.currentWindow) {
                                compositorRoot.currentWindow.child.takeFocus();
                            }
                        }
                    }
                }
            }
        }
    ]
}
