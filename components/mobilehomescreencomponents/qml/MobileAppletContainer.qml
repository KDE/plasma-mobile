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

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "private" as Private

ContainmentLayoutManager.BasicAppletContainer {
    id: appletContainer
    
    property var homeScreenState
    property real screenWidth: homeScreenState.availableScreenWidth
    property real screenHeight: homeScreenState.availableScreenHeight
    
    // HACK: for some reason configOverlayComponent access the appletContainer id
    property var container: appletContainer
    
    configOverlayComponent: Private.ConfigOverlay {
        onRequestEditModeClose: container.editMode = false;
        onRequestRemoveTrigger: container.applet.action("remove").trigger();
    }
    
    property LauncherDragManager launcherDragManager

    onEditModeChanged: {
        launcherDragManager.active = dragActive || editMode;
    }

    property real dragCenterX
    property real dragCenterY

    editModeCondition: ContainmentLayoutManager.ItemContainer.AfterPressAndHold

    onDragActiveChanged: {
        launcherDragManager.active = dragActive || editMode;
        if (dragActive) {
            // Must be 0, 0 as at this point dragCenterX and dragCenterY are on the drag before"
            launcherDragManager.startDrag(appletContainer);
            launcherDragManager.currentlyDraggedDelegate = appletContainer;
            // Reparenting removed focus
            appletContainer.forceActiveFocus();
        } else {
            launcherDragManager.dropItem(appletContainer, dragCenterX, dragCenterY);
            plasmoid.editMode = false;
            launcherRepeater.stopScrollRequested();
            launcherDragManager.currentlyDraggedDelegate = null;
            forceActiveFocus();
        }
    }
    onUserDrag: {
        dragCenterX = dragCenter.x;
        dragCenterY = dragCenter.y;
        launcherDragManager.dragItem(appletContainer, dragCenter.x, dragCenter.y);

        var pos = plasmoid.fullRepresentationItem.mapFromItem(appletContainer, dragCenter.x, dragCenter.y);

        //SCROLL LEFT
        if (pos.x < PlasmaCore.Units.gridUnit) {
            launcherRepeater.scrollLeftRequested();
        //SCROLL RIGHT
        } else if (pos.x > screenWidth - PlasmaCore.Units.gridUnit) {
            launcherRepeater.scrollRightRequested();
        //DON't SCROLL
        } else {
            launcherRepeater.stopScrollRequested();
        }

        appletContainer.x = Math.max(0, Math.min(screenWidth - appletContainer.width, appletContainer.x));
    }
    onWidthChanged: {
        if (appletContainer.x + appletContainer.width > screenWidth * Math.max(1, Math.ceil(appletContainer.x / screenWidth))) {
            appletsLayout.releaseSpace(appletContainer);
            appletContainer.width = (screenWidth * Math.max(1, Math.ceil(appletContainer.x / screenWidth)) - appletContainer.x);
            appletsLayout.positionItem(appletContainer);
        }
    }
    
    Connections {
        target: appletsLayout
        function onAppletsLayoutInteracted() {
            appletContainer.editMode = false;
        }
    }
    Connections {
        target: dropArea
        function onWidthChanged () {
            let spaceReleased = false;
            if (appletContainer.width > screenWidth || appletContainer.height > screenHeight) {
                appletsLayout.releaseSpace(appletContainer);
                appletContainer.width = Math.min(appletContainer.width, screenWidth);
                appletContainer.height = Math.min(appletContainer.height, screenHeight);
                spaceReleased = true;
            }
            if (Math.floor((appletContainer.x) / screenWidth) < Math.floor((appletContainer.x + appletContainer.width/2) / screenWidth)) {
                appletsLayout.releaseSpace(appletContainer);
                appletContainer.x = Math.floor((appletContainer.x + appletContainer.width) / screenWidth) * screenWidth;
                appletsLayout.positionItem(appletContainer);
                spaceReleased = false;

            } else if (Math.floor((appletContainer.x + appletContainer.width/2) / screenWidth) < Math.floor((appletContainer.x + appletContainer.width) / screenWidth)) {
                appletsLayout.releaseSpace(appletContainer);
                appletContainer.x = Math.ceil(appletContainer.x / screenWidth) * screenWidth - screenWidth;
                appletsLayout.positionItem(appletContainer);
                spaceReleased = false;
            }
            if (spaceReleased) {
                appletsLayout.positionItem(appletContainer);
            }
        }
    }
}

