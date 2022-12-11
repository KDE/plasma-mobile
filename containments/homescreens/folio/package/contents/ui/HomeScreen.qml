/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragDrop

import "private" as Private
import "appdrawer"

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.phone.homescreen.default 1.0 as HomeScreenLib

Item {
    id: root

    required property real topMargin
    required property real bottomMargin
    required property real leftMargin
    required property real rightMargin
    
    property bool interactive: true

    property var homeScreenState: HomeScreenState {
        interactive: root.interactive

        totalPagesWidth: pages.contentWidth
        
        appDrawerFlickable: appDrawer.flickable
        
        availableScreenHeight: height - root.topMargin - root.bottomMargin
        availableScreenWidth: width - root.leftMargin - root.rightMargin
        
        appDrawerBottomOffset: favoriteStrip.height
    }
    
    property alias appDrawer: appDrawerLoader.item
    property alias homeScreenContents: contents
    
    Component.onCompleted: {
        // ensure that homescreen is on first page
        homeScreenState.goToPageIndex(0);
        homeScreenState.resetSwipeState();
    }
    
    // the parent of the homescreen is a flickable that captures all flicks
    FlickContainer {
        id: flickContainer
        anchors.fill: parent
        
        homeScreenState: root.homeScreenState
        
        // disable flick tracking when necessary
        interactive: root.interactive && homeScreenState.currentView !== HomeScreenState.AppDrawerView && !contents.inAppletEditMode

        // item is effectively anchored to root, while allowing flickContainer
        // to keep track of flicks
        Item {
            x: flickContainer.contentX
            y: flickContainer.contentY
            width: flickContainer.width
            height: flickContainer.height
            
            // horizontal pages
            HomeScreenPages {
                id: pages
                homeScreenState: root.homeScreenState

                // account for panels
                anchors.fill: parent
                anchors.topMargin: root.topMargin
                anchors.bottomMargin: root.bottomMargin
                anchors.leftMargin: root.leftMargin
                anchors.rightMargin: root.rightMargin
                
                // animation when app drawer is being shown
                opacity: root.appDrawer ? 1 - root.appDrawer.openFactor : 1
                transform: Translate {
                    y: root.appDrawer ? (-pages.height / 20) * root.appDrawer.openFactor : 0
                }

                contentWidth: Math.max(width, width * Math.ceil(contents.itemsBoundingRect.width/width)) + (contents.launcherDragManager.active ? width : 0)
                showAddPageIndicator: contents.launcherDragManager.active

                HomeScreenContents {
                    id: contents
                    homeScreenState: root.homeScreenState
                    
                    height: pages.height
                    width: pages.width * 100
                    
                    favoriteStrip: favoriteStrip
                    homeScreenPages: pages
                }
                
                footer: FavoriteStrip {
                    id: favoriteStrip

                    appletsLayout: contents.appletsLayout
                    visible: favoriteStrip.flow.children.length > 0 || contents.launcherDragManager.active || contents.containsDrag
                    opacity: contents.launcherDragManager.active && HomeScreenLib.DesktopModel.favoriteCount >= HomeScreenLib.DesktopModel.maxFavoriteCount ? 0.3 : 1

                    TapHandler {
                        target: favoriteStrip
                        enabled: flickContainer.interactive // only interactive when we flick on homescreen
                        onTapped: {
                            //Hides icons close button
                            contents.appletsLayout.appletsLayoutInteracted();
                            contents.appletsLayout.editMode = false;
                        }
                        onLongPressed: {
                            if (homeScreenState.currentSwipeState === HomeScreenState.DeterminingType) {
                                // only go into edit mode when not in a swipe
                                contents.appletsLayout.editMode = true;
                            }
                        }
                        onPressedChanged: root.parent.focus = true;
                    }
                }
            }
            
            // app drawer
            AppDrawerLoader {
                id: appDrawerLoader
                anchors.fill: parent
                homeScreenState: root.homeScreenState
                
                // account for panels
                topPadding: root.topMargin
                bottomPadding: root.bottomMargin
                leftPadding: root.leftMargin
                rightPadding: root.rightMargin
            }
        }
    }
}
