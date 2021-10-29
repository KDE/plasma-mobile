/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtra
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents
import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

FocusScope {
    id: root
    width: 640
    height: 480

    property Item toolBox

//BEGIN functions

    function recalculateMaxFavoriteCount() {
        if (!componentComplete) {
            return;
        }

        HomeScreenComponents.ApplicationListModel.maxFavoriteCount = Math.max(4, Math.floor(Math.min(width, height) / homeScreenContents.appletsLayout.cellWidth));
    }

//END functions

//BEGIN API implementation
    Connections {
        target: MobileShell.HomeScreenControls
        
        property real lastRequestedPosition: 0
        function onResetHomeScreenPosition() {
            mainFlickable.scrollToPage(0);
            root.appDrawer.close();
        }
        function onSnapHomeScreenPosition() {
            if (lastRequestedPosition < 0) {
                root.appDrawer.open();
            } else {
                root.appDrawer.close();
            }
        }
        function onRequestRelativeScroll(pos) {
            root.appDrawer.offset -= pos.y;
            lastRequestedPosition = pos.y;
        }
    }
//END API implementation

    property bool componentComplete: false
    onWidthChanged: recalculateMaxFavoriteCount()
    onHeightChanged:recalculateMaxFavoriteCount()
    
    Component.onCompleted: {
        // ApplicationListModel doesn't have a plasmoid as is not the one that should be doing writing
        HomeScreenComponents.ApplicationListModel.loadApplications();
        HomeScreenComponents.FavoritesModel.applet = plasmoid;
        HomeScreenComponents.FavoritesModel.loadApplications();

        // set API variables
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreen = root;
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window;
        }
        componentComplete = true;
        recalculateMaxFavoriteCount()
        
        // ensure the gestures work immediately on load
        forceActiveFocus();
    }

    Plasmoid.onScreenChanged: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreen = root
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window
        }
    }
    Window.onWindowChanged: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window
        }
    }

    HomeScreenComponents.FlickablePages {
        id: mainFlickable

        anchors {
            fill: parent
            topMargin: plasmoid.availableScreenRect.y
            bottomMargin: plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
        }

        appletsLayout: homeScreenContents.appletsLayout

        appDrawer: root.appDrawer
        contentWidth: Math.max(width, width * Math.ceil(homeScreenContents.itemsBoundingRect.width/width)) + (homeScreenContents.launcherDragManager.active ? width : 0)
        showAddPageIndicator: homeScreenContents.launcherDragManager.active

        dragGestureEnabled: root.focus && (!appDrawer || appDrawer.status !== HomeScreenComponents.AbstractAppDrawer.Status.Open) && !appletsLayout.editMode && !plasmoid.editMode && !homeScreenContents.launcherDragManager.active

        HomeScreenComponents.HomeScreenContents {
            id: homeScreenContents
            width: mainFlickable.width * 100
            favoriteStrip: favoriteStrip
        }
        
        footer: HomeScreenComponents.FavoriteStrip {
            id: favoriteStrip

            appletsLayout: homeScreenContents.appletsLayout
            visible: flow.children.length > 0 || homeScreenContents.launcherDragManager.active || homeScreenContents.containsDrag
            opacity: homeScreenContents.launcherDragManager.active && HomeScreenComponents.ApplicationListModel.favoriteCount >= HomeScreenComponents.ApplicationListModel.maxFavoriteCount ? 0.3 : 1

            TapHandler {
                target: favoriteStrip
                onTapped: {
                    //Hides icons close button
                    homeScreenContents.appletsLayout.appletsLayoutInteracted();
                    homeScreenContents.appletsLayout.editMode = false;
                }
                onLongPressed: homeScreenContents.appletsLayout.editMode = true;
                onPressedChanged: root.focus = true;
            }
        }
    }

    // listview/gridview header
    property int headerHeight: Math.round(PlasmaCore.Units.gridUnit * 3)
    property string appDrawerType: "gridview" // gridview/listview
    property alias appDrawer: appDrawerLoader.item
    
    Plasmoid.onActivated: {
        console.log("Triggered!", plasmoid.nativeInterface.showingDesktop)

        // there's a couple of steps:
        // - minimize windows
        // - open app drawer
        // - restore windows
        if (!plasmoid.nativeInterface.showingDesktop) {
            plasmoid.nativeInterface.showingDesktop = true
        } else if (appDrawer.status !== HomeScreenComponents.AppDrawer.Status.Open) {
            mainFlickable.currentIndex = 0
            root.appDrawer.open()
        } else {
            plasmoid.nativeInterface.showingDesktop = false
            root.appDrawer.close()
        }
    }
    
    Component {
        id: headerComponent
        PlasmaCore.ColorScope {
            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
            
            RowLayout {
                anchors.topMargin: PlasmaCore.Units.smallSpacing
                anchors.leftMargin: PlasmaCore.Units.largeSpacing
                anchors.rightMargin: PlasmaCore.Units.largeSpacing
                anchors.fill: parent
                spacing: PlasmaCore.Units.smallSpacing
                
                PlasmaExtra.Heading {
                    color: "white"
                    level: 1
                    text: i18n("Applications")
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents.ToolButton {
                    icon.name: "view-list-symbolic"
                    implicitWidth: Math.round(PlasmaCore.Units.gridUnit * 2.1)
                    implicitHeight: Math.round(PlasmaCore.Units.gridUnit * 2.1)
                    onClicked: {
                        if (root.appDrawerType !== "listview") {
                            root.appDrawerType = "listview";
                            appDrawer.flickable.goToBeginning(); // jump to top
                        }
                    }
                }
                PlasmaComponents.ToolButton {
                    icon.name: "view-grid-symbolic"
                    implicitWidth: Math.round(PlasmaCore.Units.gridUnit * 2.1)
                    implicitHeight: Math.round(PlasmaCore.Units.gridUnit * 2.1)
                    onClicked: {
                        if (root.appDrawerType !== "gridview") {
                            root.appDrawerType = "gridview";
                            appDrawer.flickable.goToBeginning(); // jump to top
                        }
                    }
                }
            }
        }
    }
    
    Component {
        id: listViewDrawer
        HomeScreenComponents.ListViewAppDrawer {
            anchors.fill: parent
            topPadding: plasmoid.availableScreenRect.y
            bottomPadding: plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
            closedPositionOffset: favoriteStrip.height
            
            headerItem: Loader {
                sourceComponent: headerComponent
            }
            headerHeight: root.headerHeight
        }
    }
    Component {
        id: gridViewDrawer
        HomeScreenComponents.GridViewAppDrawer {
            anchors.fill: parent
            topPadding: plasmoid.availableScreenRect.y
            bottomPadding: plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
            closedPositionOffset: favoriteStrip.height
            
            headerItem: Loader {
                sourceComponent: headerComponent
            }
            headerHeight: root.headerHeight
        }
    }

    Loader {
        id: appDrawerLoader
        anchors.fill: parent
        sourceComponent: appDrawerType === "gridview" ? gridViewDrawer : listViewDrawer
    }
}

