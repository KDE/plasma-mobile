/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root
    
    property alias flickablePages: mainFlickable
    property alias homeScreenContents: contents
    
    // listview/gridview header
    property string appDrawerType: "gridview" // gridview/listview
    property alias appDrawer: appDrawerLoader.item
    
    readonly property real headerHeight: Math.round(PlasmaCore.Units.gridUnit * 3)
    
//BEGIN functions
    function activate() {
        // there's a couple of steps:
        // - minimize windows
        // - open app drawer
        // - restore windows
        if (!plasmoid.nativeInterface.showingDesktop) {
            plasmoid.nativeInterface.showingDesktop = true
        } else if (appDrawer.status !== HomeScreenComponents.AbstractAppDrawer.Status.Open) {
            mainFlickable.currentIndex = 0
            root.appDrawer.open()
        } else {
            plasmoid.nativeInterface.showingDesktop = false
            root.appDrawer.close()
        }
    }
//END functions
    
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

        dragGestureEnabled: root.parent.focus && (!root.appDrawer || root.appDrawer.status !== HomeScreenComponents.AbstractAppDrawer.Status.Open) && !appletsLayout.editMode && !plasmoid.editMode && !homeScreenContents.launcherDragManager.active

        HomeScreenComponents.HomeScreenContents {
            id: contents
            width: mainFlickable.width * 100
            favoriteStrip: favoriteStrip
        }
        
        footer: HomeScreenComponents.FavoriteStrip {
            id: favoriteStrip

            appletsLayout: homeScreenContents.appletsLayout
            visible: favoriteStrip.flow.children.length > 0 || homeScreenContents.launcherDragManager.active || homeScreenContents.containsDrag
            opacity: homeScreenContents.launcherDragManager.active && HomeScreenComponents.ApplicationListModel.favoriteCount >= HomeScreenComponents.ApplicationListModel.maxFavoriteCount ? 0.3 : 1

            TapHandler {
                target: favoriteStrip
                onTapped: {
                    //Hides icons close button
                    homeScreenContents.appletsLayout.appletsLayoutInteracted();
                    homeScreenContents.appletsLayout.editMode = false;
                }
                onLongPressed: homeScreenContents.appletsLayout.editMode = true;
                onPressedChanged: root.parent.focus = true;
            }
        }
    }
    
    Component {
        id: headerComponent
        
        AppDrawerHeader {
            onSwitchToListRequested: {
                if (root.appDrawerType !== "listview") {
                    root.appDrawerType = "listview";
                    appDrawer.flickable.goToBeginning(); // jump to top
                }
            }
            
            onSwitchToGridRequested: {
                if (root.appDrawerType !== "gridview") {
                    root.appDrawerType = "gridview";
                    appDrawer.flickable.goToBeginning(); // jump to top
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
