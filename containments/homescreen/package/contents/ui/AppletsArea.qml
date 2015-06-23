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

import "LayoutManager.js" as LayoutManager

MouseEventListener {
    id: headerItem
    z: 999
    property Item layout: appletsLayout
    property Item lastSpacer: spacer
    property Item favoritesStrip: favoritesView
    width: root.width
    height: mainLayout.Layout.minimumHeight
    property int margin: stripe.height + units.gridUnit * 2
    property Item draggingApplet
    
    onPressAndHold: {
        print(favoritesView.contains(mapToItem(favoritesView, mouse.x, mouse.y)))
        if (!root.locked && !favoritesView.contains(mapToItem(favoritesView, mouse.x, mouse.y))) {
            editOverlay.visible = true;
            var pos = mapToItem(appletsLayout, mouse.x, mouse.y);
            draggingApplet = appletsSpace.layout.childAt(pos.x, pos.y);

            if (draggingApplet) {
                draggingApplet.animationsEnabled = false;
                dndSpacer.Layout.minimumHeight = draggingApplet.height;
                LayoutManager.insertBefore(draggingApplet, dndSpacer);
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

        draggingApplet.y = mouse.y - draggingApplet.height/2;
        draggingApplet.x = mouse.x - draggingApplet.width/2;

        var pos = mapToItem(appletsLayout, mouse.x, mouse.y);
        var itemUnderMouse = appletsSpace.layout.childAt(pos.x, pos.y);

        if (itemUnderMouse && itemUnderMouse != dndSpacer) {
            dndSpacer.parent = colorScope;
            if (pos.y < itemUnderMouse.y + itemUnderMouse.height/2) {
                LayoutManager.insertBefore(itemUnderMouse, dndSpacer);
            } else {
                LayoutManager.insertAfter(itemUnderMouse, dndSpacer);
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
        if (draggingApplet.x > -draggingApplet.width/4 && draggingApplet.x < draggingApplet.width/4) {
            draggingApplet.x = 0;
            LayoutManager.insertBefore( dndSpacer, draggingApplet);
            draggingApplet.animationsEnabled = true;
        } else {
            draggingApplet.applet.action("remove").trigger();
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
            Layout.fillWidth: true
            Layout.minimumHeight: root.height
            Layout.maximumHeight: root.height
            Clock {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: goUp.top
                    margins: units.largeSpacing
                }
            }
            PlasmaCore.IconItem {
                id: goUp
                source: "go-up"
                width: units.iconSizes.huge
                height: width
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
            }
        }
        Item {
            id: spacer
            Layout.fillWidth: true
            Layout.minimumHeight: 0
            Layout.maximumHeight: Layout.minimumHeight
        }
        PlasmaCore.ColorScope {
            id: colorScope
            //TODO: decide what color we want applets
            colorGroup: PlasmaCore.Theme.NormalColorGroup
            Layout.fillWidth: true
            Layout.minimumHeight: appletsLayout.Layout.minimumHeight
            Layout.maximumHeight: appletsLayout.Layout.maximumHeight
            ColumnLayout {
                id: appletsLayout
            }
            Item {
                id: dndSpacer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: plasmoid.applets.length % 2 == 0 ? 0 : (root.height - margin)/2
                Layout.maximumHeight: Layout.minimumHeight
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: margin
            Layout.maximumHeight: Layout.minimumHeight
        }
    }
    SatelliteStripe {
        id: stripe
        z: 99
        property int viewPos: applicationsView.contentItem.height * applicationsView.visibleArea.yPosition

        y: Math.max(viewPos + plasmoid.availableScreenRect.y + krunner.inputHeight - units.smallSpacing, 
            Math.min(parent.height, viewPos + plasmoid.availableScreenRect.y + plasmoid.availableScreenRect.height - height) + Math.max(0, -(parent.height - height + applicationsView.contentY)))

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
            cellWidth: root.buttonHeight
            cellHeight: cellWidth

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
            