// SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Window

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop as DragDrop

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell.state as MobileShellState

Item {
    id: root
    
    required property real topMargin
    required property real bottomMargin
    required property real leftMargin
    required property real rightMargin

    required property bool interactive
    required property var searchWidget
    
    property alias page: swipeView.currentIndex
    
    function triggerHomescreen() {
        swipeView.setCurrentIndex(0);
        favoritesView.closeFolder();
        favoritesView.goToBeginning();
        gridAppList.goToBeginning();
    }
    
    function openConfigure() {
        if (!MobileShellState.Shell.taskSwitcherVisible) {
            plasmoid.action("configure").trigger();
            plasmoid.editMode = false;
        }
    }
    
    QQC2.SwipeView {
        id: swipeView
        opacity: 1 - searchWidget.openFactor
        interactive: root.interactive
        
        anchors.fill: parent
        anchors.topMargin: root.topMargin
        anchors.bottomMargin: root.bottomMargin
        anchors.leftMargin: root.leftMargin
        anchors.rightMargin: root.rightMargin
        
        Item {
            height: swipeView.height
            width: swipeView.width
            
            // open wallpaper menu when held on click
            TapHandler {
                onLongPressed: root.openConfigure()
            }
            
            FavoritesView {
                id: favoritesView
                anchors.fill: parent
                searchWidget: root.searchWidget
                interactive: root.interactive
                onOpenConfigureRequested: root.openConfigure()
            }
        }
        
        QQC2.ScrollView {
            width: swipeView.width
            height: swipeView.height

            // disable horizontal scrollbar
            QQC2.ScrollBar.horizontal: QQC2.ScrollBar { policy: QQC2.ScrollBar.AlwaysOff }

            GridAppList {
                id: gridAppList
                
                property int horizontalMargin: Math.round(swipeView.width  * 0.05)
                interactive: root.interactive
                leftMargin: horizontalMargin
                rightMargin: horizontalMargin
            }
        }
    }
}
