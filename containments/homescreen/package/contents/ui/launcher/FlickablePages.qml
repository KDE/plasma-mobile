/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
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

import "launcher" as Launcher
//TODO: everything using this will eventually move in Launcher
import "launcher/private" as LauncherPrivate

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.phone.homescreen 1.0

import org.kde.plasma.private.mobileshell 1.0 as MobileShell


Flickable {
    id: mainFlickable

    anchors {
        fill: parent
        topMargin: plasmoid.availableScreenRect.y
        bottomMargin: favoriteStrip.height + plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
    }

    opacity: 1 - appDrawer.openFactor
    transform: Translate {
        y: -mainFlickable.height/10 * appDrawer.openFactor
    }
    scale: (3 - appDrawer.openFactor) /3

    //bottomMargin: favoriteStrip.height
    contentWidth: appletsLayout.width
    contentHeight: height
    //interactive: !plasmoid.editMode && !launcherDragManager.active
    interactive: false

    signal cancelEditModeForItemsRequested
    onDragStarted: cancelEditModeForItemsRequested()
    onDragEnded: cancelEditModeForItemsRequested()
    onFlickStarted: cancelEditModeForItemsRequested()
    onFlickEnded: cancelEditModeForItemsRequested()

    onContentYChanged: MobileShell.HomeScreenControls.homeScreenPosition = contentY

    LauncherPrivate.DragGestureHandler {
        id: gestureHandler
        target: appletsLayout
        appDrawer: appDrawer
        mainFlickable: mainFlickable
        enabled: root.focus && appDrawer.status !== Launcher.AppDrawer.Status.Open && !appletsLayout.editMode && !plasmoid.editMode && !launcherDragManager.active
        onSnapPage: root.snapPage();
    }

    NumberAnimation {
        id: scrollAnim
        target: mainFlickable
        properties: "contentX"
        duration: units.longDuration
        easing.type: Easing.InOutQuad
    }


    PlasmaComponents.PageIndicator {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: PlasmaCore.Units.gridUnit * 2
        }
        PlasmaCore.ColorScope.inherit: false
        PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        parent: mainFlickable
        count: Math.ceil(dropArea.width / mainFlickable.width)
        visible: count > 1
        currentIndex: Math.round(mainFlickable.contentX / mainFlickable.width)
    }
}


