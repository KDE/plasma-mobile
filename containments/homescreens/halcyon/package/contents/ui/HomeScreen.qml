// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Window

import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop as DragDrop

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin
import org.kde.plasma.private.mobileshell as MobileShell

import "settings" as Settings

Item {
    id: root
    property MobileShell.MaskManager maskManager

    required property real topMargin
    required property real bottomMargin
    required property real leftMargin
    required property real rightMargin

    required property bool interactive
    required property var searchWidget

    property alias page: swipeView.currentIndex

    property bool settingsOpen: false
    property real settingsOpenFactor: settingsOpen ? 1 : 0

    signal wallpaperSelectorTriggered()

    Behavior on settingsOpenFactor {
        NumberAnimation { duration: 200 }
    }

    function triggerHomescreen() {
        swipeView.setCurrentIndex(0);
        swipeView.focusChild();
        favoritesView.closeFolder();
        favoritesView.goToBeginning();
        gridAppList.goToBeginning();
    }

    function openConfigure() {
        settingsOpen = true;
    }

    function openContainmentSettings() {
        Plasmoid.internalAction("configure").trigger();
        Plasmoid.editMode = false;
    }

    WindowPlugin.WindowMaximizedTracker {
        id: windowMaximizedTracker
        screenGeometry: Plasmoid.containment.screenGeometry

        onShowingWindowChanged: {
            if (windowMaximizedTracker.showingWindow) {
                swipeView.focusChild();
            }
        }
    }

    Settings.SettingsScreen {
        id: settings
        bottomMargin: root.bottomMargin
        anchors.fill: parent
        opacity: root.settingsOpenFactor
        visible: opacity > 0
        homeScreen: root
        z: 1
    }

    QQC2.SwipeView {
        id: swipeView
        opacity: Math.min(1 - root.settingsOpenFactor, 1 - searchWidget.openFactor)
        interactive: root.interactive

        anchors.fill: parent
        anchors.topMargin: root.topMargin
        anchors.bottomMargin: root.bottomMargin
        anchors.leftMargin: root.leftMargin
        anchors.rightMargin: root.rightMargin

        function focusChild() {
            currentItem.focusRequested();
        }

        onCurrentIndexChanged: focusChild()

        Item {
            height: swipeView.height
            width: swipeView.width

            signal focusRequested()

            // open wallpaper menu when held on click
            TapHandler {
                onPressedChanged: {
                    if (pressed) {
                        favoritesView.resetHighlight();
                    }
                }

                onLongPressed: root.openConfigure()
                onDoubleTapped: {
                    if (Plasmoid.settings.doubleTapToLock) {
                        deviceLock.triggerLock();
                    }
                }
            }

            MobileShell.DeviceLock {
                id: deviceLock
            }

            FavoritesView {
                id: favoritesView
                anchors.fill: parent
                maskManager: root.maskManager
                searchWidget: root.searchWidget
                interactive: root.interactive && swipeView.contentItem.contentX === 0
                onOpenConfigureRequested: root.openConfigure()

                onPageForwardRequested: {
                    swipeView.setCurrentIndex(1);
                    swipeView.focusChild();
                    resetHighlight();
                }
            }
        }

        Item {
            width: swipeView.width
            height: swipeView.height

            signal focusRequested()

            GridAppList {
                id: gridAppList

                anchors.fill: parent

                property int horizontalMargin: Math.round(swipeView.width * 0.05)
                interactive: root.interactive
                leftMargin: horizontalMargin
                rightMargin: horizontalMargin

                leftEdgeCallback: () => {
                    swipeView.setCurrentIndex(0);
                    swipeView.focusChild();
                    currentIndex = -1;
                }
            }
        }
    }
}
