// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

ContainmentItem {
    id: root

    Component.onCompleted: {
        Folio.FolioSettings.load();
        Folio.ApplicationListModel.load();
        Folio.FavouritesModel.load();
        Folio.PageListModel.load();

        // ensure the gestures work immediately on load
        forceActiveFocus();
    }

    Loader {
        id: wallpaperBlurLoader
        active: Folio.FolioSettings.showWallpaperBlur
        anchors.fill: parent

        sourceComponent: Item {
            id: wallpaper
            anchors.fill: parent

            // only take samples from wallpaper when we need the blur for performance
            ShaderEffectSource {
                id: controlledWallpaperSource
                anchors.fill: parent

                sourceItem: Plasmoid.wallpaperGraphicsObject
                live: blur.visible
                hideSource: false
                visible: false
            }

            // wallpaper blur
            // we attempted to use MultiEffect in the past, but it had very poor performance on the PinePhone
            FastBlur {
                id: blur
                radius: 50
                cached: true
                source: controlledWallpaperSource
                anchors.fill: parent
                visible: opacity > 0
                opacity: Math.min(1, 
                    Math.max(
                        1 - homeScreen.contentOpacity,
                        Folio.HomeScreenState.appDrawerOpenProgress * 2, // blur faster during swipe
                        Folio.HomeScreenState.searchWidgetOpenProgress * 1.5, // blur faster during swipe
                        Folio.HomeScreenState.folderOpenProgress
                    )
                )
            }
        }
    }

    function homeAction() {
        const isInWindow = (!WindowPlugin.WindowUtil.isShowingDesktop && WindowPlugin.WindowMaximizedTracker.showingWindow);

        if (isInWindow) {
            Folio.HomeScreenState.closeFolder();
            Folio.HomeScreenState.closeSearchWidget();
            Folio.HomeScreenState.closeAppDrawer();
            Folio.HomeScreenState.goToPage(0);
        } else {
            switch (Folio.HomeScreenState.viewState) {
                case Folio.HomeScreenState.PageView:
                    if (Folio.HomeScreenState.currentPage === 0) {
                        Folio.HomeScreenState.openAppDrawer();
                    } else {
                        Folio.HomeScreenState.goToPage(0);
                    }
                    break;
                case Folio.HomeScreenState.AppDrawerView:
                    Folio.HomeScreenState.closeAppDrawer();
                    break;
                case Folio.HomeScreenState.SearchWidgetView:
                    Folio.HomeScreenState.closeSearchWidget();
                    break;
                case Folio.HomeScreenState.FolderView:
                    Folio.HomeScreenState.closeFolder();
                    break;
            }
        }
    }

    Plasmoid.onActivated: homeAction()

    Rectangle {
        id: appDrawerBackground
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)

        opacity: Folio.HomeScreenState.appDrawerOpenProgress
    }

    Rectangle {
        id: searchWidgetBackground
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)

        opacity: Folio.HomeScreenState.searchWidgetOpenProgress
    }

    Rectangle {
        id: settingsViewBackground
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)

        opacity: Folio.HomeScreenState.settingsOpenProgress
    }

    MobileShell.HomeScreen {
        id: homeScreen
        anchors.fill: parent

        plasmoidItem: root
        onResetHomeScreenPosition: {
            // NOTE: empty, because this is handled by homeAction()
        }

        onHomeTriggered: root.homeAction()

        contentItem: Item {

            // homescreen component
            HomeScreen {
                id: folioHomeScreen
                anchors.fill: parent

                topMargin: homeScreen.topMargin
                bottomMargin: homeScreen.bottomMargin
                leftMargin: homeScreen.leftMargin
                rightMargin: homeScreen.rightMargin

                // make the homescreen not interactable when task switcher or startup feedback is on
                interactive: !homeScreen.overlayShown
            }
        }

        // listen to app launch errors
        Connections {
            target: Folio.ApplicationListModel
            function onLaunchError(msg) {
                MobileShellState.ShellDBusClient.closeAppLaunchAnimation()
            }
        }
    }
}

