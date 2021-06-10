/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.12 as Kirigami

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
import "indicators/providers" as IndicatorProviders

Item {
    id: root
    width: 480
    height: 30

    Plasmoid.backgroundHints: showingApp ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground

    property Item toolBox
    property int buttonHeight: width/4
    property bool reorderingApps: false
    property var layoutManager: LayoutManager

    readonly property color backgroundColor: NanoShell.StartupFeedback.visible ? NanoShell.StartupFeedback.backgroundColor : topPanel.colorScopeColor
    readonly property bool showingApp: !MobileShell.HomeScreenControls.homeScreenVisible

    readonly property bool hasTasks: tasksModel.count > 0

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    function addApplet(applet, x, y) {
        var compactContainer = compactContainerComponent.createObject(topPanel.applets)
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

       // applet.fullRepresentationItem.parent = fullContainer;
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
            Layout.minimumWidth: applet && applet.compactRepresentationItem ? Math.max(applet.compactRepresentationItem.Layout.minimumWidth, topPanel.applets.height) : topPanel.applets.height
            Layout.maximumWidth: Layout.minimumWidth
        }
    }

    Component {
        id: fullContainerComponent
        FullContainer {}
    }

    Component {
        id: fullNotificationsContainerComponent
        FullNotificationsContainer {}
    }

    // indicator providers
    IndicatorProviders.BatteryProvider {
        id: batteryProvider
    }
    IndicatorProviders.BluetoothProvider {
        id: bluetoothProvider
    }
    property alias signalStrengthProvider: signalStrengthProviderLoader.item
    Loader {
        id: signalStrengthProviderLoader
        source: Qt.resolvedUrl("indicators/providers/SignalStrengthProvider.qml")
    }
    IndicatorProviders.VolumeProvider {
        id: volumeProvider
    }
    IndicatorProviders.WifiProvider {
        id: wifiProvider
    }
    
    // top panel component
    IndicatorsRow {
        id: topPanel
        anchors.fill: parent
        z: 1
        colorGroup: showingApp ? PlasmaCore.Theme.HeaderColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
        backgroundColor: !showingApp ? "transparent" : root.backgroundColor
        showGradientBackground: !showingApp
        showDropShadow: !showingApp
    }
    
    // initial swipe down
    MouseArea {
        z: 99
        property int oldMouseY: 0

        anchors.fill: parent
        onPressed: {
            slidingPanel.cancelAnimations();
            slidingPanel.drawerX = Math.min(Math.max(0, mouse.x - slidingPanel.drawerWidth/2), slidingPanel.width - slidingPanel.contentItem.width)
            slidingPanel.userInteracting = true;
            slidingPanel.flickable.contentY = slidingPanel.closedContentY;
            oldMouseY = mouse.y;
            slidingPanel.visible = true;
        }
        onPositionChanged: {
            slidingPanel.updateOffset(mouse.y - oldMouseY);
            oldMouseY = mouse.y;
        }
        onReleased: {
            slidingPanel.userInteracting = false;
            slidingPanel.updateState();
        }
        onCanceled: {
            slidingPanel.userInteracting = false;
            slidingPanel.updateState();
        }
    }

    // sliding component
    SlidingContainer {
        id: slidingPanel
        width: plasmoid.availableScreenRect.width
        height: plasmoid.availableScreenRect.height
        topPanelHeight: topPanel.height
        topEmptyAreaHeight: quickSettings.topEmptyAreaHeight
        collapsedHeight: quickSettings.collapsedHeight
        fullyOpenHeight: quickSettings.implicitHeight
        
        appletsShown: fullRepresentationView.count > 0
        
        offset: quickSettings.height
        
        onClosed: quickSettings.closed()

        contentItem: MouseArea {
            // mousearea captures touch presses so that the flickable picks them up for swiping
            implicitWidth: slidingPanel.wideScreen ? panelContents.implicitWidth : slidingPanel.width
            implicitHeight: Math.min(slidingPanel.height, quickSettings.implicitHeight)

            GridLayout {
                id: panelContents
                width: slidingPanel.wideScreen ? Math.min(parent.width, implicitWidth) : parent.width
                
                columns: slidingPanel.wideScreen ? 2 : 1
                rows: slidingPanel.wideScreen ? 1 : 2
                
                QuickSettingsPanel {
                    id: quickSettings

                    property int trueHeight: height + Math.round(Kirigami.Units.gridUnit * 1.5) // add height of bottom bar

                    z: 4
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: slidingPanel.wideScreen ? Math.min(slidingPanel.width/2, units.gridUnit * 25) : panelContents.width

                    parentSlidingPanel: slidingPanel
                    onExpandRequested: slidingPanel.expand()
                    onCloseRequested: slidingPanel.close()
                }

                // notifications and media player
                ListView {
                    id: fullRepresentationView
                    implicitHeight: units.gridUnit * 20
                    Layout.preferredWidth: slidingPanel.wideScreen ? Math.min(slidingPanel.width/2, quickSettings.width*fullRepresentationModel.count) : panelContents.width 
                    Layout.preferredHeight: slidingPanel.wideScreen
                            ? Math.min(units.gridUnit * 20, Math.max(units.gridUnit * 15, quickSettings.implicitHeight))
                            : Math.min(plasmoid.screenGeometry.height - quickSettings.implicitHeight - bottomBar.height + slidingPanel.topEmptyAreaHeight, implicitHeight)

                    z: 1
                    interactive: true//count > 0 && width < contentWidth

                    clip: slidingPanel.wideScreen
                    y: slidingPanel.wideScreen ? 0 : quickSettings.trueHeight
                    opacity: {
                        if (slidingPanel.wideScreen) {
                            return 1;
                        } else {
                            return fullRepresentationModel.count > 0 && slidingPanel.offset / slidingPanel.collapsedHeight;
                        }
                    }
                    //preferredHighlightBegin: slidingPanel.drawerX

                    cacheBuffer: width * 100
                    highlightFollowsCurrentItem: true
                    highlightRangeMode: ListView.ApplyRange
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
