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
import org.kde.plasma.core 2.0 as PlasmaCore
import "WindowManagement.js" as WindowManagement

Rectangle {
    property alias showSplash: splash.visible
    property bool showHome: true
    property bool showPanel: true
    readonly property alias layers: layers
    readonly property real topBarHeight: units.iconSizes.small
    readonly property real bottomBarHeight: units.iconSizes.large
    property var currentWindow: null

    id: compositorRoot
    color: "black"

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
        z: showHome ? 2 : 1
    }

    Item {
        id: windowsLayer
        anchors.fill: parent
        anchors.topMargin: topBarHeight
        anchors.bottomMargin: bottomBar.height
        z: showHome ? 1 : 2
    }

    Item {
        id: panelLayer
        anchors.fill: parent
        z: showPanel ? 3 : 0
    }

    Rectangle {
        id: bottomBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: (showSplash || showHome) ? 0 : bottomBarHeight
        color: "black"
        z: showHome ? 0 : 2

        Behavior on height {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                duration: units.shortDuration
            }
        }

        RowLayout {
            anchors.fill: parent

            PlasmaCore.IconItem {
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                width: units.iconSizes.smallMedium
                height: width
                source: "window-close"

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: units.iconSizes.medium
                Layout.preferredHeight: units.iconSizes.medium

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (currentWindow) {
                            currentWindow.close();
                            currentWindow = null;
                        }
                    }
                }
            }

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
                    onClicked: showHome = true
                }
            }
        }
    }
}
