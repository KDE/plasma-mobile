// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15

import org.kde.kirigami 2.20 as Kirigami

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

ContainmentItem {
    id: root

    // filled in by the shell (Panel.qml) with the plasma-workspace PanelView
    property var panel: null
    onPanelChanged: {
        setWindowProperties()
    }

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    readonly property bool inLandscape: Screen.width > Screen.height;

    readonly property real navigationPanelHeight: Kirigami.Units.gridUnit * 2

    readonly property real intendedWindowThickness: navigationPanelHeight
    readonly property real intendedWindowLength: inLandscape ? Screen.height : Screen.width
    readonly property real intendedWindowOffset: inLandscape ? MobileShell.Constants.topPanelHeight : 0; // offset for top panel
    readonly property int intendedWindowLocation: inLandscape ? PlasmaCore.Types.RightEdge : PlasmaCore.Types.BottomEdge

    onIntendedWindowLengthChanged: maximizeTimer.restart() // ensure it always takes up the full length of the screen
    onIntendedWindowLocationChanged: locationChangeTimer.restart()
    onIntendedWindowOffsetChanged: {
        if (root.panel) {
            root.panel.offset = intendedWindowOffset;
        }
    }

    // use a timer so we don't have to maximize for every single pixel
    // - improves performance if the shell is run in a window, and can be resized
    Timer {
        id: maximizeTimer
        running: false
        interval: 100
        onTriggered: {
            // maximize first, then we can apply offsets (otherwise they are overridden)
            root.panel.maximize()
            root.panel.offset = intendedWindowOffset;
        }
    }

    // use a timer so that rotation events are faster (offload the panel movement to later, after everything is figured out)
    Timer {
        id: locationChangeTimer
        running: false
        interval: 100
        onTriggered: root.panel.location = intendedWindowLocation
    }

    function setWindowProperties() {
        if (root.panel) {
            root.panel.maximize(); // maximize first, then we can apply offsets (otherwise they are overridden)
            root.panel.offset = intendedWindowOffset;
            root.panel.thickness = navigationPanelHeight;
            root.panel.location = intendedWindowLocation;
        }
    }

    Connections {
        target: root.panel

        // HACK: There seems to be some component that overrides our initial bindings for the panel,
        //   which is particularly problematic on first start (since the panel is misplaced)
        // - We set an event to override any attempts to override our bindings.
        function onLocationChanged() {
            if (root.panel.location !== root.intendedWindowLocation) {
                root.setWindowProperties();
            }
        }

        function onThicknessChanged() {
            if (root.panel.thickness !== root.intendedWindowThickness) {
                root.setWindowProperties();
            }
        }
    }

    Component.onCompleted: setWindowProperties();

    // only opaque if there are no maximized windows on this screen
    readonly property bool opaqueBar: WindowPlugin.WindowMaximizedTracker.showingWindow

    Item {
        anchors.fill: parent

        // contrasting colour
        Kirigami.Theme.colorSet: opaqueBar ? Kirigami.Theme.Window : Kirigami.Theme.Complementary
        Kirigami.Theme.inherit: false

        // load appropriate system navigation component
        NavigationPanelComponent {
            anchors.fill: parent
            opaqueBar: root.opaqueBar
        }
    }
}
