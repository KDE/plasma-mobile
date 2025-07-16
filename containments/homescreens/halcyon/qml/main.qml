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
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

import plasma.applet.org.kde.plasma.mobile.homescreen.halcyon as Halcyon

ContainmentItem {
    id: root

    Component.onCompleted: {
        Plasmoid.settings.load();
        Plasmoid.pinnedModel.load();

        Halcyon.ApplicationListModel.loadApplications();
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

    property MobileShell.MaskManager maskManager: MobileShell.MaskManager {
        height: root.height
        width: root.width
    }

    property MobileShell.MaskManager frontMaskManager: MobileShell.MaskManager {
        height: root.height
        width: root.width
    }

    // wallpaper blur layer
    MobileShell.BlurEffect {
        id: wallpaperBlur
        active: Plasmoid.settings.wallpaperBlurEffect > 0
        anchors.fill: parent
        sourceLayer: Plasmoid.wallpaperGraphicsObject
        maskSourceLayer: Plasmoid.settings.wallpaperBlurEffect > 1 ? maskManager.maskLayer : null

        fullBlur: Math.min(1,
                           Math.max(1 - homeScreen.contentOpacity,
                                    halcyonHomeScreen.settingsOpenFactor,
                                    root.darkenBackgroundFactor,
                                    search.openFactor
                           )
        )
    }

    property real darkenBackgroundFactor: halcyonHomeScreen.page == 1 ? 1 : 0
    Behavior on darkenBackgroundFactor {
        NumberAnimation { duration: Kirigami.Units.longDuration }
    }

    Rectangle {
        id: darkenBackground
        color: Qt.rgba(0, 0, 0, 0.2 + (0.5 * root.darkenBackgroundFactor))
        anchors.fill: parent
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
                maskManager: root.maskManager

                topMargin: homeScreen.topMargin
                bottomMargin: homeScreen.bottomMargin
                leftMargin: homeScreen.leftMargin
                rightMargin: homeScreen.rightMargin

                searchWidget: search
                interactive: true

                onWallpaperSelectorTriggered: wallpaperSelectorLoader.active = true
            }

            // search component
            SearchWidget {
                id: search
                anchors.fill: parent
                visible: openFactor > 0

                topPadding: homeScreen.topMargin
                bottomPadding: homeScreen.bottomMargin
                leftPadding: homeScreen.leftMargin
                rightPadding: homeScreen.rightMargin

                onReleaseFocusRequested: halcyonHomeScreen.forceActiveFocus()
            }
        }
    }

    // top blur layer for items on top of the base homescreen
    MobileShell.BlurEffect {
        id: homescreenBlur
        anchors.fill: parent
        active: Plasmoid.settings.wallpaperBlurEffect > 1 && wallpaperSelectorLoader.active
        visible: active
        fullBlur: 0

        sourceLayer: homeScreenLayer
        maskSourceLayer: frontMaskManager.maskLayer

        // stacking both wallpaper and homescreen layers so we can blur them in one pass
        Item {
            id: homeScreenLayer
            anchors.fill: parent
            opacity: 0

            // wallpaper blur
            ShaderEffectSource {
                anchors.fill: parent

                textureSize: homescreenBlur.textureSize
                sourceItem: Plasmoid.wallpaperGraphicsObject
                hideSource: false
            }

            // homescreen blur
            ShaderEffectSource {
                anchors.fill: parent

                textureSize: homescreenBlur.textureSize
                sourceItem: homeScreen
                hideSource: false
            }
        }
    }

    // loader for wallpaper selector
    Loader {
        id: wallpaperSelectorLoader
        anchors.fill: parent
        asynchronous: true
        active: false

        onLoaded: {
            wallpaperSelectorLoader.item.open();
        }

        sourceComponent: MobileShell.WallpaperSelector {
            maskManager: root.frontMaskManager
            horizontal: root.width > root.height
            edge: horizontal ? Qt.LeftEdge : Qt.BottomEdge
            bottomMargin: horizontal ? 0 : halcyonHomeScreen.bottomMargin
            leftMargin: horizontal ? halcyonHomeScreen.leftMargin : 0
            rightMargin: horizontal ? halcyonHomeScreen.rightMargin : 0
            onClosed: {
                wallpaperSelectorLoader.active = false;
            }

            onWallpaperSettingsRequested: {
                close();
                halcyonHomeScreen.openContainmentSettings();
            }
        }
    }
}


