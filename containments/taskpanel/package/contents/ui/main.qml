/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15
import QtGraphicalEffects 1.12

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.phone.taskpanel 1.0 as TaskPanel

PlasmaCore.ColorScope {
    id: root
    width: 360
    
    // contrasting colour
    colorGroup: !plasmoid.nativeInterface.allMinimized ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup

    readonly property color backgroundColor: PlasmaCore.ColorScope.backgroundColor

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    
    // toggle visibility of navigation bar (show, or use gestures only)
    Binding {
        target: plasmoid.Window.window // assumed to be plasma-workspace "PanelView" component
        property: "visibilityMode"
        // 0 - VisibilityMode.NormalPanel
        // 3 - VisibilityMode.WindowsGoBelow
        value: MobileShell.MobileShellSettings.navigationPanelEnabled ? 0 : 3
    }
    Binding {
        target: plasmoid.Window.window // assumed to be plasma-workspace "PanelView" component
        property: "thickness"
        // height of panel:
        // - if navigation panel is enabled: PlasmaCore.Units.gridUnit * 2
        // - if gestures only is enabled: 8 (just large enough for touch swipe to register, without blocking app content)
        value: MobileShell.MobileShellSettings.navigationPanelEnabled ? PlasmaCore.Units.gridUnit * 2 : 8
    }
    
//BEGIN API implementation

    Binding {
        target: MobileShell.TaskPanelControls
        property: "isPortrait"
        value: Screen.width <= Screen.height
    }
    Binding {
        target: MobileShell.TaskPanelControls
        property: "panelHeight"
        value: MobileShell.MobileShellSettings.navigationPanelEnabled ? root.height : 0
    }
    Binding {
        target: MobileShell.TaskPanelControls
        property: "panelWidth"
        value: MobileShell.MobileShellSettings.navigationPanelEnabled ? root.width : 0
    }

    Connections {
        target: plasmoid.nativeInterface
        function onAllMinimizedChanged() {
            MobileShell.HomeScreenControls.homeScreenVisible = plasmoid.nativeInterface.allMinimized
        }
    }
    
//END API implementation
    
    Window.onWindowChanged: {
        if (!Window.window)
            return;

        // ensure that Plasma sets the correct offset
        Window.window.offset = Qt.binding(() => {
            return (plasmoid.formFactor === PlasmaCore.Types.Vertical) ? MobileShell.TopPanelControls.panelHeight : MobileShell.TopPanelControls.panelWidth
        });
    }
    
    // bottom navigation panel component
    Component {
        id: navigationPanel 
        NavigationPanelComponent {
            taskSwitcher: MobileShell.HomeScreenControls.taskSwitcher
        }
    }
    
    // bottom navigation gesture area component
    Component {
        id: navigationGesture 
        MobileShell.NavigationGestureArea {
            taskSwitcher: MobileShell.HomeScreenControls.taskSwitcher
        }
    }
    
    // load appropriate system navigation component
    Loader {
        id: navigationLoader
        anchors.fill: parent
        sourceComponent: MobileShell.MobileShellSettings.navigationPanelEnabled ? navigationPanel : navigationGesture
    }
    
    // landscape vs. portrait orientation of panel
    states: [
        State {
            name: "landscape"
            when: MobileShell.Shell.orientation === MobileShell.Shell.Landscape
            PropertyChanges {
                target: plasmoid.nativeInterface
                // only show on right edge if gestures are not enabled
                location: MobileShell.MobileShellSettings.navigationPanelEnabled ? PlasmaCore.Types.RightEdge : PlasmaCore.Types.BottomEdge
            }
        }, State {
            name: "portrait"
            when: MobileShell.Shell.orientation === MobileShell.Shell.Portrait
            PropertyChanges {
                target: plasmoid.nativeInterface
                location: PlasmaCore.Types.BottomEdge
            }
        }
    ]
}
