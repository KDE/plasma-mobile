/*
 *  Copyright 2015 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

MouseEventListener {
    id: headerItem
    z: 999
    property Item layout: appletsLayout
    property Item lastSpacer: spacer
    property Item favoritesStrip: favoritesView
    width: root.width
    height: Math.max(applicationsView.height - stripe.height, mainLayout.Layout.minimumHeight)
    property int margin: stripe.height + units.gridUnit * 2
    property Item draggingApplet
    property int startMouseX
    property int startMouseY
    property int oldMouseX
    property int oldMouseY

    EventGenerator {
        id: eventGenerator
    }

    SequentialAnimation {
        id: removeAnim
        property Item target
        property real to
        NumberAnimation {
            properties: "x"
            duration: units.longDuration
            easing.type: Easing.InOutQuad
            target: removeAnim.target
            to: removeAnim.to
        }
        ScriptAction {
            script: removeAnim.target.applet.action("remove").trigger();
        }
    }

    onPressed: {
    }
    onPressAndHold: {
        print(favoritesView.contains(mapToItem(favoritesView, mouse.x, mouse.y)))
        if (!favoritesView.contains(mapToItem(favoritesView, mouse.x, mouse.y))) {
            editOverlay.visible = true;
            var pos = mapToItem(appletsLayout, mouse.x, mouse.y);
            draggingApplet = appletsSpace.layout.childAt(pos.x, pos.y);
            editOverlay.applet = draggingApplet;

            startMouseX = mouse.screenX;
            startMouseY = mouse.screenY;
            oldMouseX = mouse.screenX;
            oldMouseY = mouse.screenY;

            eventGenerator.sendGrabEvent(draggingApplet, EventGenerator.UngrabMouse);
            eventGenerator.sendGrabEvent(headerItem, EventGenerator.GrabMouse);
            eventGenerator.sendMouseEvent(headerItem, EventGenerator.MouseButtonPress, mouse.x, mouse.y, Qt.LeftButton, Qt.LeftButton, 0)

            if (draggingApplet) {
                draggingApplet.animationsEnabled = false;
                dndSpacer.height = draggingApplet.height;
                root.layoutManager.insertBefore(draggingApplet, dndSpacer);
                draggingApplet.parent = headerItem;

                pos = mapToItem(headerItem, mouse.x, mouse.y);
                draggingApplet.y = pos.y - draggingApplet.height/2;

                applicationsView.interactive = false;
            }
        }
    }
    onPositionChanged: {
        if (!draggingApplet) {
            return;
        }

        applicationsView.interactive = false;
        if (Math.abs(mouse.screenX - startMouseX) > units.gridUnit ||
            Math.abs(mouse.screenY - startMouseY) > units.gridUnit) {
            editOverlay.opacity = 0;
        }

        draggingApplet.x -= oldMouseX - mouse.screenX;
        draggingApplet.y -= oldMouseY - mouse.screenY;
        oldMouseX = mouse.screenX;
        oldMouseY = mouse.screenY;

        var pos = mapToItem(appletsLayout, mouse.x, mouse.y);
        var itemUnderMouse = appletsSpace.layout.childAt(pos.x, pos.y);

        if (itemUnderMouse && itemUnderMouse != dndSpacer) {
            dndSpacer.parent = colorScope;
            if (pos.y < itemUnderMouse.y + itemUnderMouse.height/2) {
                root.layoutManager.insertBefore(itemUnderMouse, dndSpacer);
            } else {
                root.layoutManager.insertAfter(itemUnderMouse, dndSpacer);
            }
        }

        pos = mapToItem(root, mouse.x, mouse.y);
        //SCROLL UP
        if (applicationsView.contentY > -applicationsView.headerItem.height + root.height && pos.y < root.height/4) {
            root.scrollUp();
        //SCROLL DOWN
        } else if (applicationsView.contentY < 0 && pos.y > 3 * (root.height / 4)) {
            root.scrollDown();
        //DON't SCROLL
        } else {
            root.stopScroll();
        }
    }
    onReleased: {
        if (!draggingApplet) {
            return;
        }

        if (draggingApplet.x > -draggingApplet.width/3 && draggingApplet.x < draggingApplet.width/3) {
            draggingApplet.x = 0;
            root.layoutManager.insertBefore( dndSpacer, draggingApplet);
        } else {
            removeAnim.target = draggingApplet;
            removeAnim.to = (draggingApplet.x > 0) ? root.width : -root.width
            removeAnim.running = true;
        }
        applicationsView.interactive = true;
        dndSpacer.parent = colorScope;
        draggingApplet = null;
    }

    ColumnLayout {
        id: mainLayout
        anchors {
            fill: parent
        }

        Item {
            Layout.minimumHeight: krunner.inputHeight
            Layout.minimumWidth: Layout.minimumHeight
        }
        PlasmaCore.ColorScope {
            id: colorScope
            //TODO: decide what color we want applets
            colorGroup: PlasmaCore.Theme.NormalColorGroup
            Layout.fillWidth: true
            Layout.minimumHeight: appletsLayout.implicitHeight
            Layout.maximumHeight: appletsLayout.implicitHeight
            Column {
                id: appletsLayout
                width: parent.width
                move: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            Item {
                id: dndSpacer
                width: parent.width
            }
        }
    }
    SatelliteStripe {
        id: stripe
        z: 99
        property int viewPos: applicationsView.contentItem.height * applicationsView.visibleArea.yPosition

        y: Math.max(viewPos + krunner.inputHeight - units.smallSpacing, 
            Math.min(parent.height, viewPos + plasmoid.availableScreenRect.height - height) )

        PlasmaCore.IconItem {
            id: goUp
            source: "go-up"
            width: units.iconSizes.huge
            height: width
            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.top
            }
            MouseArea {
                anchors {
                    fill: parent
                    margins: -units.smallSpacing
                }
                onClicked: applicationsView.flick(0, -applicationsView.height/2)
            }
        }

        GridView {
            id: favoritesView
            //FIXME: QQuickItem has a contains, but seems to not work
            function contains(point) {
                return point.x > 0 && point.x < width && point.y > 0 && point.y < height;
            }
            anchors.fill: parent
            property int columns: 4
            interactive: false
            flow: GridView.FlowTopToBottom

            cellWidth: root.width / 4
            cellHeight: root.buttonHeight

            model: plasmoid.nativeInterface.applicationListModel
            delegate: HomeLauncher {
                maximumLineCount: 1
            }

            move: Transition {
                NumberAnimation {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                    properties: "x,y"
                }
            }
            moveDisplaced: Transition {
                NumberAnimation {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                    properties: "x,y"
                }
            }
        }
    }
}
