/*
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

/**
 * Window with the ActionDrawer component embedded in it.
 *
 * Used for overlaying the ActionDrawer if the original window does not cover
 * the whole screen.
 */
NanoShell.FullScreenOverlay {
    id: window

    /**
     * The ActionDrawer component.
     */
    property alias actionDrawer: drawer

    visible: drawer.intendedToBeVisible
    width: Screen.width
    height: Screen.height

    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            window.raise();
        }
    }

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
