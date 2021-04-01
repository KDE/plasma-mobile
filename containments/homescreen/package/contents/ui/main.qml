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
import org.kde.draganddrop 2.0 as DragDrop

import "launcher" as Launcher
//TODO: everything using this will eventually move in Launcher
import "launcher/private" as LauncherPrivate

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.phone.homescreen 1.0

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

        plasmoid.nativeInterface.applicationListModel.maxFavoriteCount = Math.max(4, Math.floor(Math.min(width, height) / homeScreenContents.appletsLayout.cellWidth));
    }

//END functions


    property bool componentComplete: false
    onWidthChanged: recalculateMaxFavoriteCount()
    onHeightChanged:recalculateMaxFavoriteCount()
    Component.onCompleted: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreen = root
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window
        }
        componentComplete = true;
        recalculateMaxFavoriteCount()
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

    Connections {
        property real lastRequestedPosition: 0
        target: MobileShell.HomeScreenControls
        function onResetHomeScreenPosition() {
            mainFlickable.scrollToPage(0);
            appDrawer.close();
        }
        function onSnapHomeScreenPosition() {
            if (lastRequestedPosition > 0) {
                appDrawer.open();
            } else {
                appDrawer.close();
            }
        }
        function onRequestHomeScreenPosition(y) {
            appDrawer.offset += y;
            lastRequestedPosition = y;
        }
    }

    Launcher.LauncherDragManager {
        id: launcherDragManager
        anchors.fill: parent
        z: 2
        appletsLayout: homeScreenContents.appletsLayout
        favoriteStrip: favoriteStrip
    }

    Launcher.FlickablePages {
        id: mainFlickable

        anchors {
            fill: parent
            topMargin: plasmoid.availableScreenRect.y
            bottomMargin: favoriteStrip.height + plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
        }

        appletsLayout: homeScreenContents.appletsLayout

        appDrawer: appDrawer
        contentWidth: Math.max(width, width * Math.ceil(homeScreenContents.itemsBoundingRect.width/width)) + (launcherDragManager.active ? width : 0)

        Launcher.HomeScreenContents {
            id: homeScreenContents
            width: mainFlickable.width * 100
            favoriteStrip: favoriteStrip
        }
    }

    Launcher.AppDrawer {
        id: appDrawer
        anchors.fill: parent

        topPadding: plasmoid.availableScreenRect.y
        bottomPadding: favoriteStrip.height + plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
    }

    Launcher.FavoriteStrip {
        id: favoriteStrip
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
        }
        appletsLayout: homeScreenContents.appletsLayout

        visible: flow.children.length > 0 || launcherDragManager.active || homeScreenContents.containsDrag

        LauncherPrivate.DragGestureHandler {
            target: favoriteStrip
            appDrawer: appDrawer
            mainFlickable: mainFlickable
            enabled: root.focus && appDrawer.status !== Launcher.AppDrawer.Status.Open && !homeScreenContents.appletsLayout.editMode && !plasmoid.editMode && !launcherDragManager.active
            onSnapPage: mainFlickable.snapPage();
        }
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

