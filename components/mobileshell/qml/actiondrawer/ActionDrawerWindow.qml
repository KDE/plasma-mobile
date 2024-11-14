/*
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.layershell 1.0 as LayerShell

/**
 * Window with the ActionDrawer component embedded in it.
 *
 * Used for overlaying the ActionDrawer if the original window does not cover
 * the whole screen.
 */
Window {
    id: window

    LayerShell.Window.scope: "overlay"
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop | LayerShell.Window.AnchorLeft | LayerShell.Window.AnchorRight | LayerShell.Window.AnchorBottom
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone

    /**
     * The ActionDrawer component.
     */
    property alias actionDrawer: drawer
    property alias intendedToBeVisible: drawer.intendedToBeVisible
    property alias state: drawer.state

    visible: true

    color: "transparent"

    Component.onCompleted: updateTouchArea()

    function updateTouchArea() {
        if (state != "" && state != "close") {
            window.raise();
            ShellUtil.setInputRegion(window, Qt.rect(0, 0, 0, 0));
        } else {
            ShellUtil.setInputRegion(window, Qt.rect(0, 0, window.width, MobileShell.Constants.topPanelHeight));
        }
    }

    onWidthChanged:  updateTouchArea()
    onIntendedToBeVisibleChanged: updateTouchArea()
    onStateChanged: updateTouchArea()

    onActiveChanged: {
        if (!active) {
            drawer.close();
        }
    }

    ActionDrawer {
        id: drawer
        anchors.fill: parent
    }
}
