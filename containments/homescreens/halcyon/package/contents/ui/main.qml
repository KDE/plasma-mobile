// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.private.mobile.homescreen.halcyon as Halcyon
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

ContainmentItem {
    id: root

    Component.onCompleted: {
        Halcyon.ApplicationListModel.loadApplications();
        Halcyon.PinnedModel.applet = root.plasmoid;
        forceActiveFocus();
    }

    Plasmoid.onActivated: {
        // there's a couple of steps:
        // - minimize windows (only if we are in an app)
        // - open app drawer
        // - close app drawer and, if necessary, restore windows

        // Always close action drawer
        if (MobileShellState.ShellDBusClient.isActionDrawerOpen) {
            MobileShellState.ShellDBusClient.closeActionDrawer();
        }

        if (!WindowPlugin.WindowUtil.isShowingDesktop && windowMaximizedTracker.showingWindow || search.isOpen) {
            // Always close the search widget as well
            if (search.isOpen) {
                search.close();
            }

            halcyonHomeScreen.page = 0;

            WindowPlugin.WindowUtil.isShowingDesktop = true;
        } else if (halcyonHomeScreen.page == 0) {
            halcyonHomeScreen.page = 1;
        } else {
            WindowPlugin.WindowUtil.isShowingDesktop = false;
            halcyonHomeScreen.page = 0;
        }
    }

    WindowPlugin.WindowMaximizedTracker {
        id: windowMaximizedTracker
        screenGeometry: Plasmoid.containment.screenGeometry
    }

    MobileShell.HomeScreenWallpaperBlur {
        id: wallpaperBlur
        active: Plasmoid.settings.showWallpaperBlur
        anchors.fill: parent
        wallpaperItem: Plasmoid.wallpaperGraphicsObject

        blurOpacity: Math.min(1,
            Math.max(1 - homeScreen.contentOpacity,
                halcyonHomeScreen.settingsOpenFactor
            )
        )
    }

    Rectangle {
        id: darkenBackground
        color: (halcyonHomeScreen.page == 1 ? Qt.rgba(0, 0, 0, 0.7) : Qt.rgba(0, 0, 0, 0.2))
        anchors.fill: parent
        Behavior on color {
            ColorAnimation { duration: Kirigami.Units.longDuration }
        }
    }

    Rectangle {
        id: darkenSettingsBackground
        color: Qt.rgba(0, 0, 0, 0.7)
        opacity: halcyonHomeScreen.settingsOpenFactor
        anchors.fill: parent
        Behavior on color {
            ColorAnimation { duration: Kirigami.Units.longDuration }
        }
    }

    MobileShell.HomeScreen {
        id: homeScreen
        anchors.fill: parent
        plasmoidItem: root

        onResetHomeScreenPosition: {
            halcyonHomeScreen.triggerHomescreen();
        }

        onHomeTriggered: {
            search.close();
        }

        // homescreen component
        contentItem: Item {
            HomeScreen {
                id: halcyonHomeScreen
                anchors.fill: parent

                topMargin: homeScreen.topMargin
                bottomMargin: homeScreen.bottomMargin
                leftMargin: homeScreen.leftMargin
                rightMargin: homeScreen.rightMargin

                searchWidget: search
                interactive: true
            }

            // search component
            MobileShell.KRunnerWidget {
                id: search
                anchors.fill: parent
                visible: openFactor > 0

                onActionTriggered: search.close()

                topMargin: homeScreen.topMargin
                bottomMargin: homeScreen.bottomMargin
                leftMargin: homeScreen.leftMargin
                rightMargin: homeScreen.rightMargin
            }
        }
    }
}


