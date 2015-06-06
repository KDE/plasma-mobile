/*
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
import org.kde.plasma.components 2.0 as PlasmaComponents
import "plasmapackage:/code/LayoutManager.js" as LayoutManager

ItemGroup {
    id: plasmoidGroup
    scale: plasmoid.scale
    canResizeHeight: true
    title: applet.title
    minimumWidth: Math.max(LayoutManager.cellSize.width,
                           appletContainer.minimumWidth +
                           plasmoidGroup.contents.anchors.leftMargin +
                           plasmoidGroup.contents.anchors.rightMargin)

    minimumHeight: Math.max(LayoutManager.cellSize.height,
                            appletContainer.minimumHeight +
                            plasmoidGroup.contents.anchors.topMargin +
                            plasmoidGroup.contents.anchors.bottomMargin)

    property alias applet: appletContainer.applet
    property alias appletContainment: appletContainer

    Item {
        id: appletContainer
        property QtObject applet
        anchors.fill: parent.contents
        onAppletChanged: {
            appletTimer.running = true
        }
    }

    Connections {
        target: plasmoid

        onAppletRemoved: {
            LayoutManager.setSpaceAvailable(plasmoidGroup.x, plasmoidGroup.y, plasmoidGroup.width, plasmoidGroup.height, true)
            if (applet.id == plasmoidGroup.applet.id) {
                plasmoidGroup.destroy()
            }
        }
    }

    PlasmaCore.SvgItem {
        svg: configIconsSvg
        elementId: "close"
        width: Math.max(16, plasmoidGroup.titleHeight - 2)
        height: width
        visible: (applet.action("remove")) ? applet.action("remove").enabled : false
        MouseArea {
            anchors.fill: parent
            onClicked: applet.action("remove").trigger();
        }
        anchors {
            right: plasmoidGroup.contents.right
            bottom: plasmoidGroup.contents.top
        }
    }

    PlasmaCore.SvgItem {
        svg: configIconsSvg
        elementId: "configure"
        width: Math.max(16, plasmoidGroup.titleHeight - 2)
        height: width
        visible: (applet.action("configure")) ? applet.action("configure").enabled : false
        MouseArea {
            anchors.fill: parent
            onClicked: applet.action("configure").trigger();
        }
        anchors {
            left: plasmoidGroup.contents.left
            bottom: plasmoidGroup.contents.top
        }
        Component.onCompleted: {
            if (action && typeof action !== "undefined") {
                action.enabled = true
            }
        }
    }


    //FIXME: this delay is because backgroundHints gets updated only after a while in qml applets
    Timer {
        id: appletTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: {
            if (applet.backgroundHints != 0) {
                plasmoidGroup.imagePath = "widgets/background"
            } else {
                plasmoidGroup.imagePath = "widgets/translucentbackground"
            }
            applet.backgroundHints = "NoBackground"
        }
    }
}
