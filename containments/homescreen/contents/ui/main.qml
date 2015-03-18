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

import QtQuick 2.1
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.satellite.components 0.1 as SatelliteComponents

import "plasmapackage:/code/LayoutManager.js" as LayoutManager

Item {
    id: root
    width: 480
    height: 640

    property Item toolBox
    property alias appletsSpace: applicationsView.headerItem
    property int buttonHeight: width/4
    property bool reorderingApps: false

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(appletsSpace.layout)
        container.visible = true
        print("Applet added: " + applet)

        var appletWidth = applet.width;
        var appletHeight = applet.height;
        applet.parent = container;
        container.applet = applet;
        applet.anchors.fill = container;
        applet.visible = true;
        container.visible = true;

        // If the provided position is valid, use it.
        if (x >= 0 && y >= 0) {
            var index = LayoutManager.insertAtCoordinates(container, x , y);

        // Fall through to determining an appropriate insert position.
        } else {
            var before = null;
            container.animationsEnabled = false;

            if (appletsSpace.lastSpacer.parent === appletsSpace.layout) {
                before = appletsSpace.lastSpacer;
            }

            if (before) {
                LayoutManager.insertBefore(before, container);

            // Fall through to adding at the end.
            } else {
                container.parent = appletsSpace.layout;
            }

            //event compress the enable of animations
            //startupTimer.restart();
        }

        if (applet.Layout.fillWidth) {
            appletsSpace.lastSpacer.parent = root;
        }
    }

    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsSpace.layout;
        LayoutManager.lastSpacer = appletsSpace.lastSpacer;
        LayoutManager.restore();
        applicationsView.contentY = -root.height;

        appListModel.appOrder = plasmoid.configuration.AppOrder;
        appListModel.loadApplications();
    }

    SatelliteComponents.ApplicationListModel {
        id: appListModel
        onAppOrderChanged: {
            plasmoid.configuration.AppOrder = appListModel.appOrder;
        }
    }

    Timer {
        id: autoScrollTimer
        property bool scrollDown: true
        repeat: true
        interval: 10
        onTriggered: {
            applicationsView.contentY += scrollDown ? 8 : -8;
            if (applicationsView.draggingItem) {
                applicationsView.draggingItem.y += scrollDown ? 8 : -8;

                applicationsView.draggingItem.updateRow();
            }
        }
    }

    Component {
        id: appletContainerComponent
        Item {
            //not used yet
            property bool animationsEnabled: false
            property Item applet
            Layout.fillWidth: true
            Layout.fillHeight: applet && applet.Layout.fillHeight
            Layout.onFillHeightChanged: {
                if (plasmoid.formFactor == PlasmaCore.Types.Vertical) {
                    checkLastSpacer();
                }
            }

            Layout.minimumWidth: root.width
            Layout.minimumHeight: Math.max(applet.Layout.minimumHeight, root.height / 2)

            Layout.preferredWidth: root.width
            Layout.preferredHeight: Layout.minimumHeight

            Layout.maximumWidth: root.width
            Layout.maximumHeight: Layout.minimumHeight
        }
    }

    Rectangle {
        color: Qt.rgba(0, 0, 0, 0.9 * (Math.min(applicationsView.contentY + root.height, root.height) / root.height))
        anchors.fill: parent
    }

    PlasmaCore.ColorScope {
        anchors.fill: parent
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

        GridView {
            id: applicationsView
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            property Item draggingItem

            cellWidth: root.buttonHeight
            cellHeight: cellWidth
            model: appListModel

            snapMode: GridView.SnapToRow

            onFlickingChanged: {
                if (!draggingVertically && contentY < -headerItem.height + root.height) {
                    scrollAnim.to = Math.round(contentY/root.height) * root.height
                    scrollAnim.running = true;
                }
            }
            onDraggingVerticallyChanged: {
                if (!draggingVertically && contentY < -headerItem.height + root.height) {
                    scrollAnim.to = Math.round(contentY/root.height) * root.height
                    scrollAnim.running = true;
                }
            }
            NumberAnimation {
                id: scrollAnim
                target: applicationsView
                properties: "contentY"
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }

            //clip: true
            delegate: HomeLauncher {}
            header: MouseArea {
                z: 999
                property Item layout: appletsLayout
                property Item lastSpacer: spacer
                width: root.width
                height: mainLayout.Layout.minimumHeight 

                onPressAndHold: {
                    plasmoid.action("configure").trigger();
                }

                ColumnLayout {
                    id: mainLayout
                    anchors {
                        fill: parent
                        bottomMargin: stripe.height + units.gridUnit * 2
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
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                bottom: parent.bottom
                            }
                        }
                    }
                    ColumnLayout {
                        id: appletsLayout
                        Layout.minimumHeight: Math.max(root.height, Math.round(Layout.preferredHeight / root.height) * root.height)
                        Item {
                            id: spacer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
                SatelliteStripe {
                    id: stripe
                    z: 99
                    property int viewPos: applicationsView.contentItem.height * applicationsView.visibleArea.yPosition

                    y: Math.max(viewPos, 
                          Math.min(parent.height, viewPos + root.height) - height + Math.max(0, -(parent.height - height + applicationsView.contentY)))

                    PlasmaCore.Svg {
                        id: stripeIcons
                        imagePath: Qt.resolvedUrl("../images/homescreenicons.svg")
                    }

                    Row {
                        anchors.fill: parent
                        property int columns: 4
                        property alias buttonHeight: stripe.height

                        HomeLauncherSvg {
                            id: phoneIcon
                            svg: stripeIcons
                            elementId: "phone"
                            callback: function() {
                                console.log("Start phone")
                            }
                        }

                        HomeLauncherSvg {
                            id: messagingIcon
                            svg: stripeIcons
                            elementId: "messaging"
                            callback: function() { console.log("Start messaging") }
                        }


                        HomeLauncherSvg {
                            id: emailIcon
                            svg: stripeIcons
                            elementId: "email"
                            callback: function() { console.log("Start email") }
                        }


                        HomeLauncherSvg {
                            id: webIcon
                            svg: stripeIcons
                            elementId: "web"
                            callback: function() { console.log("Start web") }
                        }
                    }
                }
            }
            footer: Item {
                width: units. gridUnit * 4
                height: width
            }
        }

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                horizontalCenter: scrollHandle.horizontalCenter
            }
            width: units.smallSpacing
            color: PlasmaCore.ColorScope.textColor
            opacity: scrollHandle.opacity / 2
        }
        Rectangle {
            id: scrollHandle
            color: PlasmaCore.ColorScope.textColor
            width: units.gridUnit
            height: width
            radius: width
            anchors.right: parent.right
            y: applicationsView.height * applicationsView.visibleArea.yPosition
            opacity: scrollbarMouse.pressed || applicationsView.flicking ? 0.8 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            MouseArea {
                id: scrollbarMouse
                anchors {
                    fill: parent
                    margins: -units.gridUnit
                }
                drag.target: parent
                onPositionChanged: {
                    applicationsView.contentY = applicationsView.contentHeight * (parent.y / applicationsView.height) - applicationsView.headerItem.height
                }
                onReleased: {
                    applicationsView.returnToBounds()
                }
            }
        }
    }
}