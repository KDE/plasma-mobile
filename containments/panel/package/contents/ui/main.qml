/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root
    
    readonly property bool showingApp: !MobileShell.HomeScreenControls.homeScreenVisible
    readonly property color backgroundColor: topPanel.colorScopeColor

    Plasmoid.backgroundHints: showingApp ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground
    
    width: 480
    height: PlasmaCore.Units.gridUnit
    
//BEGIN API implementation

    Binding {
        target: MobileShell.TopPanelControls
        property: "panelHeight"
        value: root.height
    }
    Binding {
        target: MobileShell.TopPanelControls
        property: "inSwipe"
        value: drawer.dragging
    }
    
    Connections {
        target: MobileShell.TopPanelControls
        
        function onStartSwipe() {
            swipeArea.startSwipe();
        }
        function onEndSwipe() {
            swipeArea.endSwipe();
        }
        function onRequestRelativeScroll(offsetY) {
            swipeArea.updateOffset(offsetY);
        }
    }
    
//END API implementation
    
    Component.onCompleted: {
        // we want to bind global shortcuts here
        MobileShell.VolumeProvider.bindShortcuts = true;
    }
    
    // top panel component
    MobileShell.StatusBar {
        id: topPanel
        anchors.fill: parent
        showDropShadow: !root.showingApp
        colorGroup: root.showingApp ? PlasmaCore.Theme.HeaderColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
        backgroundColor: !root.showingApp ? "transparent" : root.backgroundColor
    }
    
    MobileShell.ActionDrawerOpenSurface {
        id: swipeArea
        actionDrawer: drawer
        anchors.fill: parent
    }
    
    MobileShell.ActionDrawer {
        id: drawer
    }
}
