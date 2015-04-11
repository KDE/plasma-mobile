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

import MeeGo.QOfono 0.2

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace

import "plasmapackage:/code/LayoutManager.js" as LayoutManager

PlasmaCore.ColorScope {
    id: root
    width: 480
    height: 640
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    property Item toolBox
    property int buttonHeight: width/4
    property bool reorderingApps: false

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(tabGroup)
        container.visible = true
        print("Applet added: " + applet)

        var appletWidth = applet.width;
        var appletHeight = applet.height;
        applet.parent = container;
        container.applet = applet;
        applet.anchors.fill = container;
        applet.visible = true;
        container.visible = true;

        //container.parent = tabs;

        //The tab
        var tab = tabComponent.createObject(tabBar.layout);
        tab.iconSource = applet.icon;
        tab.tab = container;
    }

    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsLayout;
        LayoutManager.restore();
    }

    RowLayout {
        id: appletsLayout
        Layout.minimumHeight: Math.max(root.height, Math.round(Layout.preferredHeight / root.height) * root.height)
    }
 
    Component {
        id: appletContainerComponent
        Item {
            //not used yet
            property bool animationsEnabled: false
            property Item applet
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component {
        id: tabComponent
        PlasmaComponents.TabButton {
            width: parent.width / parent.children.length
            height: units.iconSizes.huge
        }
    }


    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    OfonoNetworkRegistration {
        id: netreg
        Component.onCompleted: {
            netreg.scan()
            updateStrengthIcon()
        }

        onNetworkOperatorsChanged : {
            console.log("operators :"+netreg.currentOperator["Name"].toString())
        }
        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
        function updateStrengthIcon() {
            if (netreg.strength >= 100) {
                strengthIcon.source = "network-mobile-100";
            } else if (netreg.strength >= 80) {
                strengthIcon.source = "network-mobile-80";
            } else if (netreg.strength >= 60) {
                strengthIcon.source = "network-mobile-60";
            } else if (netreg.strength >= 40) {
                strengthIcon.source = "network-mobile-40";
            } else if (netreg.strength >= 20) {
                strengthIcon.source = "network-mobile-20";
            } else {
                strengthIcon.source = "network-mobile-0";
            }
        }

        onStrengthChanged: {
            console.log("Strength changed to " + netreg.strength)
            updateStrengthIcon()
        }
    }

    Rectangle {
        parent: slidingPanel.visible ? panelContents : root
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: root.height
        color: PlasmaCore.ColorScope.backgroundColor

        PlasmaCore.IconItem {
            id: strengthIcon
            colorGroup: PlasmaCore.ColorScope.colorGroup
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: height
            height: parent.height
        }
        PlasmaComponents.Label {
            anchors {
                left: strengthIcon.right
                verticalCenter: parent.verticalCenter
            }
            text: netreg.strength + "% " + netreg.name
            color: PlasmaCore.ColorScope.textColor
            font.pixelSize: parent.height / 2
        }
        PlasmaComponents.Label {
            id: clock
            anchors.fill: parent
            text: Qt.formatTime(timeSource.data.Local.DateTime, "hh:mm")
            color: PlasmaCore.ColorScope.textColor
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: height / 2
        }


            PlasmaWorkspace.BatteryIcon {
                id: batteryIcon
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: height
                height: parent.height
                hasBattery: pmSource.data["Battery"]["Has Battery"]
            // batteryType: "Phone"
                percent: pmSource.data["Battery0"] ? pmSource.data["Battery0"]["Percent"] : 0

                PlasmaCore.DataSource {
                    id: pmSource
                    engine: "powermanagement"
                    connectedSources: sources
                    onSourceAdded: {
                        disconnectSource(source);
                        connectSource(source);
                    }
                    onSourceRemoved: {
                        disconnectSource(source);
                    }
                }
            }
            Rectangle {
                height: units.smallSpacing/2
                color: PlasmaCore.ColorScope.highlightColor
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }
        }
        MouseArea {
            property int oldMouseY: 0

            anchors.fill: parent
            onPressed: {
                oldMouseY = mouse.y;
                slidingPanel.visibility = Qt.WindowFullScreen;
            }
            onPositionChanged: {
                //var factor = (mouse.y - oldMouseY > 0) ? (1 - Math.max(0, (slidingArea.y + slidingPanel.overShoot) / slidingPanel.overShoot)) : 1
                var factor = 1;
                slidingPanel.offset = slidingPanel.offset + (mouse.y - oldMouseY) * factor;
                oldMouseY = mouse.y;
            }
            onReleased: slidingPanel.updateState();
        }

        SlidingPanel {
            id: slidingPanel
            width: plasmoid.availableScreenRect.width
            height: plasmoid.availableScreenRect.height
            contents: Item {
                id: panelContents
                anchors.fill: parent

                PlasmaComponents.TabBar {
                    id: tabBar
                    visible: plasmoid.applets.count > 1
                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                        margins: units.smallSpacing
                    }
                    height: units.iconSizes.huge
                }
                PlasmaComponents.TabGroup {
                    id: tabGroup
                    anchors {
                        left: parent.left
                        top: plasmoid.applets.count > 1 ? tabBar.bottom : parent.top
                        right: parent.right
                        bottom: parent.bottom
                        margins: units.smallSpacing
                    }
                }
            }
        }
}
