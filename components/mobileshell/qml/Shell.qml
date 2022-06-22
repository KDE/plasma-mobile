/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Window 2.15

pragma Singleton

/**
 * Provides access to the homescreen plasmoid containment within the shell.
 */
QtObject {
    id: delegate

    /**
     * Top margin from the screen edge where application windows would display.
     */
    readonly property real topMargin: TopPanelControls.panelHeight
    
    /**
     * Bottom margin from the screen edge where application windows would display.
     */
    readonly property real bottomMargin: TaskPanelControls.isPortrait ? TaskPanelControls.panelHeight : 0
    
    /**
     * Left margin from the screen edge where application windows would display.
     */
    readonly property real leftMargin: 0
    
    /**
     * Right margin from the screen edge where application windows would display.
     */
    readonly property real rightMargin: !TaskPanelControls.isPortrait ? TaskPanelControls.panelWidth : 0
    
    /**
     * Orientation of the mobile device.
     */
    readonly property int orientation: TaskPanelControls.isPortrait ? Shell.Portrait : Shell.Landscape

    enum Orientation {
        Landscape,
        Portrait
    }
}
