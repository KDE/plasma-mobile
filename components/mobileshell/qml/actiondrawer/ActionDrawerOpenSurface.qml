/*
 *  SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

/**
 * Component that triggers the opening and closing of an ActionDrawer when dragged on with touch or mouse.
 */
MouseArea {
    id: root
    
    required property ActionDrawer actionDrawer
    
    property int oldMouseY: 0

    function startSwipe() {
        if (actionDrawer.visible) {
            // ensure the action drawer state is consistent
            actionDrawer.closeImmediately();
        }
        actionDrawer.cancelAnimations();
        actionDrawer.dragging = true;
        actionDrawer.opened = false;
        
        // must be after properties other are set, we cannot have actionDrawer.updateState() be called
        actionDrawer.offset = 0;
        actionDrawer.oldOffset = 0;
        actionDrawer.visible = true;
    }
    
    function endSwipe() {
        actionDrawer.dragging = false;
        actionDrawer.updateState();
    }
    
    function updateOffset(offsetY) {
        actionDrawer.offset += offsetY;
    }
    
    anchors.fill: parent
    onPressed: mouse => {
        oldMouseY = mouse.y;
        
        // if the user swiped from the top left, otherwise it's from the top right
        if (mouse.x < root.width / 2) {
            actionDrawer.openToPinnedMode = MobileShell.MobileShellSettings.actionDrawerTopLeftMode == MobileShell.MobileShellSettings.Pinned;
        } else {
            actionDrawer.openToPinnedMode = MobileShell.MobileShellSettings.actionDrawerTopRightMode == MobileShell.MobileShellSettings.Pinned;
        }
        
        startSwipe();
    }
    onReleased: endSwipe()
    onCanceled: endSwipe()
    onPositionChanged: mouse => {
        updateOffset(mouse.y - oldMouseY);
        oldMouseY = mouse.y;
    }
}
