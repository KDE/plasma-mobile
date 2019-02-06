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
import QtQuick.Layouts 1.3

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace

import "LayoutManager.js" as LayoutManager

import "quicksettings"

PlasmaCore.ColorScope {
    id: root
    width: 480
    height: 640
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    property Item toolBox
    property int buttonHeight: width/4
    property bool reorderingApps: false
    property var layoutManager: LayoutManager

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(appletIconsRow)
        print("Applet added: " + applet + " " + applet.title)
        container.width = units.iconSizes.medium
        container.height = container.height

        applet.parent = container;
        container.applet = applet;
        applet.anchors.fill = container;
        applet.visible = true;
        container.visible = true;
        if (applet.pluginName == "org.kde.phone.notifications") {
            //FIXME: make a way to instantiate fullRepresentationItem without the open/close dance
            applet.expanded = true
            applet.expanded = false
            applet.fullRepresentationItem.parent = notificationsParent;
            notificationsParent.applet = applet;
            applet.fullRepresentationItem.anchors.fill = notificationsParent;
        } else {
            quickSettings.addPlasmoid(applet);
        }
    }

    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsLayout;
        LayoutManager.restore();
    }

    PlasmaCore.DataSource {
        id: statusNotifierSource
        engine: "statusnotifieritem"
        interval: 0
        onSourceAdded: {
            connectSource(source)
        }
        Component.onCompleted: {
            connectedSources = sources
        }
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
            Layout.fillHeight: true
            Layout.minimumWidth: applet && applet.compactRepresentationItem ? Math.max(applet.compactRepresentationItem.Layout.minimumWidth, appletIconsRow.height) : appletIconsRow.height
            Layout.maximumWidth: Layout.minimumWidth
        }
    }

    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    Rectangle {
        z: 1
        parent: slidingPanel.visible ? panelContents : root
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: root.height
        color: PlasmaCore.ColorScope.backgroundColor

        Loader {
            id: strengthLoader
            height: parent.height
            width: item ? item.width : 0
            source: Qt.resolvedUrl("SignalStrength.qml")
        }

        Row {
            id: sniRow
            anchors.left: strengthLoader.right
            height: parent.height
            Repeater {
                id: statusNotifierRepeater
                model: PlasmaCore.SortFilterModel {
                    id: filteredStatusNotifiers
                    filterRole: "Title"
                    sourceModel: PlasmaCore.DataModel {
                        dataSource: statusNotifierSource
                    }
                }

                delegate: TaskWidget {
                }
            }
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

        RowLayout {
            id: appletIconsRow
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            height: parent.height
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
        z: 99
        property int oldMouseY: 0

        anchors.fill: parent
        onPressed: {
            slidingPanel.userInteracting = true;
            oldMouseY = mouse.y;
            slidingPanel.visible = true;
        }
        onPositionChanged: {
            //var factor = (mouse.y - oldMouseY > 0) ? (1 - Math.max(0, (slidingArea.y + slidingPanel.overShoot) / slidingPanel.overShoot)) : 1
            var factor = 1;
            slidingPanel.offset = slidingPanel.offset + (mouse.y - oldMouseY) * factor;
            oldMouseY = mouse.y;
        }
        onReleased: {
            slidingPanel.userInteracting = false;
            slidingPanel.updateState();
        }
    }

    SlidingPanel {
        id: slidingPanel
        width: plasmoid.availableScreenRect.width
        height: plasmoid.availableScreenRect.height
        peekHeight: quickSettingsParent.height + notificationsParent.minimumHeight + root.height
        headerHeight: root.height
        onExpandedChanged: {
            modeSwitchAnim.running = false;
            modeSwitchAnim.to = expanded ? width : 0
            modeSwitchAnim.running = true;
        }
        contents: Item {
            id: panelContents
            anchors.fill: parent
            implicitHeight: slidingPanel.expanded ? (slidingPanel.height-slidingPanel.headerHeight)*0.8 :  (quickSettingsParent.height + notificationsParent.height + root.height)
            Rectangle {
                id: quickSettingsParent
                parent: slidingPanel.fixedArea
                color: PlasmaCore.ColorScope.backgroundColor
                z: 2
                width: parent.width
                y: Math.min(0, slidingPanel.offset - height - root.height)
                height: quickSettings.Layout.minimumHeight
                QuickSettings {
                    id: quickSettings
                    anchors.fill: parent
                }
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom:parent.bottom
                    }
                    height: units.devicePixelRatio
                    color: PlasmaCore.ColorScope.textColor
                    opacity: 0.2
                    visible: slidingPanel.offset + slidingPanel.headerHeight < panelContents.height
                }
            }
            Item {
                id: notificationsParent
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    right: parent.right
                    bottomMargin: root.height
                }
                property var applet
                height: applet ? applet.fullRepresentationItem.Layout.maximumHeight : 0
                property int minimumHeight: applet ? applet.fullRepresentationItem.Layout.minimumHeight : 0
            }
        }
    }
}
