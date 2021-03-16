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

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace
import org.kde.taskmanager 0.1 as TaskManager

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "LayoutManager.js" as LayoutManager

import "quicksettings"
import "indicators" as Indicators


Item {
    id: root
    width: 480
    height: 30

    Plasmoid.backgroundHints: showingApp ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground

    property Item toolBox
    property int buttonHeight: width/4
    property bool reorderingApps: false
    property var layoutManager: LayoutManager

    readonly property color backgroundColor: NanoShell.StartupFeedback.visible ? NanoShell.StartupFeedback.backgroundColor : icons.backgroundColor
    readonly property bool showingApp: !MobileShell.HomeScreenControls.homeScreenVisible

    readonly property bool hasTasks: tasksModel.count > 0

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    function addApplet(applet, x, y) {
        var compactContainer = compactContainerComponent.createObject(appletIconsRow)
        print("Applet added: " + applet + " " + applet.title)

        applet.parent = compactContainer;
        compactContainer.applet = applet;
        applet.anchors.fill = compactContainer;
        applet.visible = true;

        //FIXME: make a way to instantiate fullRepresentationItem without the open/close dance
        applet.expanded = true
        applet.expanded = false

        var fullContainer = null;
        if (applet.pluginName == "org.kde.plasma.notifications") {
            fullContainer = fullNotificationsContainerComponent.createObject(fullRepresentationView.contentItem, {"fullRepresentationModel": fullRepresentationModel, "fullRepresentationView": fullRepresentationView});
        } else {
            fullContainer = fullContainerComponent.createObject(fullRepresentationView.contentItem, {"fullRepresentationModel": fullRepresentationModel, "fullRepresentationView": fullRepresentationView});
        }

        applet.fullRepresentationItem.parent = fullContainer;
        fullContainer.applet = applet;
        fullContainer.contentItem = applet.fullRepresentationItem;
        //applet.fullRepresentationItem.anchors.fill = fullContainer;
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
        //FIXME: workaround
        Component.onCompleted: tasksModel.countChanged();
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
 
    //todo: REMOVE?
    Component {
        id: compactContainerComponent
        Item {
            property Item applet
            visible: applet && (applet.status != PlasmaCore.Types.HiddenStatus && applet.status != PlasmaCore.Types.PassiveStatus)
            Layout.fillHeight: true
            Layout.minimumWidth: applet && applet.compactRepresentationItem ? Math.max(applet.compactRepresentationItem.Layout.minimumWidth, appletIconsRow.height) : appletIconsRow.height
            Layout.maximumWidth: Layout.minimumWidth
        }
    }

    Component {
        id: fullContainerComponent
        FullContainer {
        }
    }

    Component {
        id: fullNotificationsContainerComponent
        FullNotificationsContainer {
        }
    }

    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    DropShadow {
        anchors.fill: icons
        visible: !showingApp
        cached: true
        horizontalOffset: 0
        verticalOffset: 1
        radius: 4.0
        samples: 17
        color: Qt.rgba(0,0,0,0.8)
        source: icons
    }

    // screen top panel
    PlasmaCore.ColorScope {
        id: icons
        z: 1
        colorGroup: showingApp ? PlasmaCore.Theme.HeaderColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
        //parent: slidingPanel.visible && !slidingPanel.wideScreen ? panelContents : root
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: root.height
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 1.0
                    color: showingApp ? root.backgroundColor : "transparent"
                }
                GradientStop {
                    position: 0.0
                    color: showingApp ? root.backgroundColor : Qt.rgba(0, 0, 0, 0.1)
                }
            }
        }

        Loader {
            id: strengthLoader
            height: parent.height
            width: item ? item.width : 0
            source: Qt.resolvedUrl("indicators/SignalStrength.qml")
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
            property bool is24HourTime: plasmoid.nativeInterface.isSystem24HourFormat
            
            anchors.fill: parent
            text: Qt.formatTime(timeSource.data.Local.DateTime, is24HourTime ? "h:mm" : "h:mm ap")
            color: PlasmaCore.ColorScope.textColor
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: height / 2
        }

        RowLayout {
            id: appletIconsRow
            anchors {
                bottom: parent.bottom
                right: simpleIndicatorsLayout.left
            }
            height: parent.height
        }

        //TODO: pluggable
        RowLayout {
            id: simpleIndicatorsLayout
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                rightMargin: units.smallSpacing
            }
            Indicators.Bluetooth {}
            Indicators.Wifi {}
            Indicators.Volume {}
            Indicators.Battery {}
        }
    }
    
    // screen top panel background (background for the rest of the screen in SlidingPanel.qml)
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.6 * Math.min(1, slidingPanel.offset/panelContents.height)
    }
    
    MouseArea {
        z: 99
        property int oldMouseY: 0

        anchors.fill: parent
        onPressed: {
            slidingPanel.cancelAnimations();
            slidingPanel.drawerX = Math.min(Math.max(0, mouse.x - slidingPanel.drawerWidth/2), slidingPanel.width - slidingPanel.contentItem.width)
            slidingPanel.userInteracting = true;
            oldMouseY = mouse.y;
            slidingPanel.offset = 0//units.gridUnit * 2;
            slidingPanel.showFullScreen();
        }
        onPositionChanged: {
            slidingPanel.offset = Math.min(slidingPanel.contentItem.height, slidingPanel.offset + (mouse.y - oldMouseY));
            
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
        openThreshold: units.gridUnit * 2
        headerHeight: root.height

        offset: quickSettingsParent.height
        
        onClosed: quickSettings.closed()

        contentItem: Item {
            implicitWidth: panelContents.implicitWidth
            implicitHeight: Math.min(slidingPanel.height, quickSettingsParent.implicitHeight)
            GridLayout {
                id: panelContents
                anchors.fill: parent
                implicitWidth: quickSettingsParent.implicitWidth
                implicitHeight: Math.min(slidingPanel.height, quickSettingsParent.implicitHeight)

                columns: slidingPanel.wideScreen ? 2 : 1
                rows: slidingPanel.wideScreen ? 1 : 2
                
                DrawerBackground {
                    id: quickSettingsParent
                    //anchors.fill: parent
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: slidingPanel.wideScreen ? Math.min(slidingPanel.width/2, units.gridUnit * 25) : panelContents.width
                    z: 4
                    contentItem: QuickSettings {
                        id: quickSettings
                        onCloseRequested: {
                            slidingPanel.hide()
                        }
                    }
                }

                ListView {
                    id: fullRepresentationView
                    z: 1
                    interactive: width < contentWidth
                    //parent: slidingPanel.wideScreen ? slidingPanel.flickable.contentItem : panelContents
                    Layout.preferredWidth: slidingPanel.wideScreen ? Math.min(slidingPanel.width - quickSettingsParent.width, quickSettingsParent.width*fullRepresentationModel.count) : panelContents.width 
                    //Layout.fillWidth: true
                    clip: slidingPanel.wideScreen
                    y: slidingPanel.wideScreen ? 0 : quickSettingsParent.height - height * (1-opacity)
                    opacity: slidingPanel.wideScreen ? 1 : fullRepresentationModel.count > 0 && slidingPanel.offset/panelContents.height
                    height: Math.min(plasmoid.screenGeometry.height - slidingPanel.headerHeight - quickSettingsParent.height - bottomBar.height, implicitHeight)
                    //leftMargin: slidingPanel.drawerX
                    preferredHighlightBegin: slidingPanel.drawerX

                    implicitHeight: units.gridUnit * 20
                    cacheBuffer: width * 100
                    highlightFollowsCurrentItem: true
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    highlightMoveDuration: units.longDuration
                    snapMode: slidingPanel.wideScreen ? ListView.NoSnap : ListView.SnapOneItem
                    model: ObjectModel {
                        id: fullRepresentationModel
                    }
                    orientation: ListView.Horizontal

                    MouseArea {
                        parent: fullRepresentationView.contentItem
                        anchors.fill: parent
                        z: -1
                        onClicked: slidingPanel.close()
                    }

                    //implicitHeight: fullRepresentationLayout.implicitHeight
                    //clip: true

                }
            }
        }
        DrawerBackground {
            id: bottomBar
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            parent: slidingPanel.fixedArea
            opacity: fullRepresentationView.opacity
            visible: !slidingPanel.wideScreen && fullRepresentationModel.count > 1
            //height: 40
            z: 100
            contentItem: RowLayout {
                PlasmaComponents.TabBar {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    position: PlasmaComponents.TabBar.Footer
                    Text {
                        text:fullRepresentationModel.count
                    }
                    Repeater {
                        model: fullRepresentationView.count
                        delegate: PlasmaComponents.TabButton {
                            implicitHeight: parent.height
                            text: fullRepresentationModel.get(index).applet.title
                            checked: fullRepresentationView.currentIndex === index
                        
                            onClicked: fullRepresentationView.currentIndex = index
                        }
                    }
                }
                PlasmaComponents.ToolButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    icon.name: "paint-none"
                    onClicked: slidingPanel.close();
                }
            }
        }
    }
}
