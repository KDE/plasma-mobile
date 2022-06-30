// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

Item {
    id: root
    
    property bool interactive: true
    required property var searchWidget
    
    property alias page: swipeView.currentIndex
    
    function triggerHomescreen() {
        swipeView.setCurrentIndex(0);
    }
    
    function openConfigure() {
        plasmoid.action("configure").trigger();
        plasmoid.editMode = false;
    }
    
    QQC2.SwipeView {
        id: swipeView
        opacity: 1 - searchWidget.openFactor
        interactive: root.interactive
        
        anchors.fill: parent
        anchors.topMargin: MobileShell.Shell.topMargin
        anchors.bottomMargin: MobileShell.Shell.bottomMargin
        anchors.leftMargin: MobileShell.Shell.leftMargin
        anchors.rightMargin: MobileShell.Shell.rightMargin
        
        Item {
            height: swipeView.height
            width: swipeView.width
            
            // open wallpaper menu when held on click
            TapHandler {
                onLongPressed: root.openConfigure()
            }
            
            FavoritesView {
                anchors.fill: parent
                searchWidget: root.searchWidget
                interactive: root.interactive
                onOpenConfigureRequested: root.openConfigure()
            }
        }
        
        ColumnLayout {
            id: column 
            height: swipeView.height
            width: swipeView.width
            
            property real horizontalMargin: Math.max(Kirigami.Units.largeSpacing, root.width * 0.1 / 2)
            
            GridAppList {
                interactive: root.interactive
                leftMargin: column.horizontalMargin
                rightMargin: column.horizontalMargin
                effectiveContentWidth: swipeView.width - leftMargin - rightMargin
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
