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

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.satellite.components 0.1 as SatelliteComponents

Item {
    id: root
    width: 640
    height: 480

    property Item toolBox
    property alias appletsSpace: applicationsView.headerItem
    property int buttonHeight: width/4

    Containment.onAppletAdded: {
        var container = appletContainerComponent.createObject(appletsSpace)
        container.visible = true
        print("Applet added: " + applet)
        applet.parent = container
        container.applet = applet
        applet.anchors.fill = applet.parent
        applet.visible = true
        container.width = 500
        container.height = 500
    }

    Component {
        id: appletContainerComponent
        Item {
            property Item applet
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
            z: 1
            cellWidth: root.buttonHeight
            cellHeight: cellWidth
            model: SatelliteComponents.ApplicationListModel {
                id: appListModel
            }
            snapMode: GridView.SnapToRow
            //clip: true
            delegate: HomeLauncher {}
            header: MouseArea {
                z: 999
                width: root.width
                height: root.height - units.iconSizes.medium

                onPressAndHold: {
                    containment.action("configure").trigger();
                }

                /*SatelliteStripe {
                    id: stripe
                    z: 99
                    y: Math.max(applications.contentY + parent.height, parent.height - height)

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
                                dialerOverlay.open()
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
                }*/
            }
        }
    }

    Component.onCompleted: {
        print("root Containment loaded")
    }
}