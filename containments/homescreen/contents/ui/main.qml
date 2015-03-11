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
    }

    SatelliteComponents.ApplicationListModel {
        id: appListModel
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
            //clip: true
            delegate: HomeLauncher {}
            header: MouseArea {
                z: 999
                property Item layout: mainLayout
                property Item lastSpacer: spacer
                width: root.width
                height: Math.max(root.height, ((root.height - units.gridUnit * 2)/2) * mainLayout.children.length)

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
                        id: spacer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
                SatelliteStripe {
                    id: stripe
                    z: 99
                    y: Math.max(applicationsView.contentY + parent.height, parent.height - height)

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
        PlasmaComponents.ScrollBar {
            flickableItem: applicationsView
            opacity: applicationsView.flicking ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}