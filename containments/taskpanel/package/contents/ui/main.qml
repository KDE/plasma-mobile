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
    colorGroup: !MobileShell.WindowUtil.allWindowsMinimized ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup

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
    
    Binding {
        target: plasmoid.Window.window
        property: "location"
        value: {
            if (MobileShell.Shell.orientation === MobileShell.Shell.Portrait) {
                return PlasmaCore.Types.BottomEdge;
            } else if (MobileShell.Shell.orientation === MobileShell.Shell.Landscape) {
                return MobileShell.MobileShellSettings.navigationPanelEnabled ? PlasmaCore.Types.RightEdge : PlasmaCore.Types.BottomEdge
            }
        }
    }
    
    // HACK: really really really make sure the dimensions are set properly
    function setBindings() {
        plasmoid.Window.window.offset = Qt.binding(() => {
            return (MobileShell.Shell.orientation === MobileShell.Shell.Landscape) ? MobileShell.TopPanelControls.panelHeight : 0;
        });
        plasmoid.Window.window.thickness = Qt.binding(() => {
            return MobileShell.MobileShellSettings.navigationPanelEnabled ? PlasmaCore.Units.gridUnit * 2 : 8
        });
        plasmoid.Window.window.length = Qt.binding(() => {
            return MobileShell.Shell.orientation === MobileShell.Shell.Portrait ? Screen.width : Screen.height;
        });
        plasmoid.Window.window.maximumLength = Qt.binding(() => {
            return MobileShell.Shell.orientation === MobileShell.Shell.Portrait ? Screen.width : Screen.height;
        });
        plasmoid.Window.window.minimumLength = Qt.binding(() => {
            return MobileShell.Shell.orientation === MobileShell.Shell.Portrait ? Screen.width : Screen.height;
        });
    }
    
    Connections {
        target: plasmoid.Window.window
        function onThicknessChanged() {
            root.setBindings();
        }
    }
    
    Component.onCompleted: setBindings();
    
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
        target: MobileShell.WindowUtil
        function onAllWindowsMinimizedChanged() {
            MobileShell.HomeScreenControls.homeScreenVisible = MobileShell.WindowUtil.allWindowsMinimized
        }
    }
    
//END API implementation
    
    Window.onWindowChanged: {
        if (!Window.window) {
            return;
        }
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
}
