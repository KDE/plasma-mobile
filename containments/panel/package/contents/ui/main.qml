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
import org.kde.taskmanager 0.1 as TaskManager

import "LayoutManager.js" as LayoutManager

import "quicksettings"

PlasmaCore.ColorScope {
    id: root
    width: 480
    height: 30
    //colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    Plasmoid.backgroundHints: showingApp ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground

    property Item toolBox
    property int buttonHeight: width/4
    property bool reorderingApps: false
    property var layoutManager: LayoutManager

    readonly property bool showingApp: tasksModel.activeTask && tasksModel.activeTask.valid && !tasksModel.data(tasksModel.activeTask, TaskManager.AbstractTasksModel.IsFullScreen)

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
            applet.preferredRepresentation = applet.compactRepresentation
            applet.switchWidth = -1;
            applet.switchHeight = -1;
        }
    }

    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsLayout;
        LayoutManager.restore();
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        filterByScreen: plasmoid.configuration.showForCurrentScreenOnly

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

    Item {
        z: 1
        //parent: slidingPanel.visible && !slidingPanel.wideScreen ? panelContents : root
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: root.height
        Rectangle {
            anchors.fill: parent
            color: PlasmaCore.ColorScope.backgroundColor
            opacity: showingApp
        }

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
    }
    MouseArea {
        z: 99
        property int oldMouseY: 0

        anchors.fill: parent
        onPressed: {
            slidingPanel.drawerX = Math.min(Math.max(0, mouse.x - slidingPanel.drawerWidth/2), slidingPanel.width - slidingPanel.drawerWidth)
            slidingPanel.userInteracting = true;
            oldMouseY = mouse.y;
            slidingPanel.offset = 0//units.gridUnit * 2;
            slidingPanel.showFullScreen();
        }
        onPositionChanged: {
            slidingPanel.offset = slidingPanel.offset + (mouse.y - oldMouseY);
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
        openThreshold: units.gridUnit * 10
        headerHeight: root.height

        contentItem: Item {
            id: panelContents
            anchors.fill: parent
            implicitWidth: quickSettingsParent.implicitWidth
            implicitHeight: quickSettingsParent.implicitHeight

            DrawerBackground {
                id: quickSettingsParent
                anchors.fill: parent
                z: 1
                contentItem: QuickSettings {
                    id: quickSettings
                }
            }

            DrawerBackground {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                y: quickSettingsParent.height - height * (1-opacity)
                opacity: slidingPanel.offset/panelContents.height
                contentItem: Item {
                    id: notificationsParent

                    property var applet
                    implicitHeight: applet ? applet.fullRepresentationItem.Layout.maximumHeight : 0
                    property int minimumHeight: applet ? applet.fullRepresentationItem.Layout.minimumHeight : 0
                }
            }
        }
    }
}
