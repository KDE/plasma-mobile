// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1
import QtQml.Models 2.15

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
    layer.enabled: true
    
    required property bool interactive
    required property var searchWidget
    
    readonly property real twoColumnThreshold: PlasmaCore.Units.gridUnit * 10
    readonly property bool twoColumn: root.width / 2 > twoColumnThreshold
    
    readonly property real cellWidth: twoColumn ? root.width / 2 : root.width
    readonly property real cellHeight: delegateHeight
    
    readonly property real leftMargin: Math.round(parent.width * 0.1)
    readonly property real rightMargin: Math.round(parent.width * 0.1)
    readonly property real delegateHeight: PlasmaCore.Units.gridUnit * 3
    
    property bool folderShown: false
    onFolderShownChanged: folderShown ? openFolderAnim.restart() : closeFolderAnim.restart()
    
    signal openConfigureRequested()
    
    FavoritesGrid {
        id: favoritesGrid
        anchors.fill: parent
        interactive: root.interactive
        searchWidget: root.searchWidget
        
        cellWidth: root.cellWidth
        cellHeight: root.cellHeight
        
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin
        twoColumn: root.twoColumn
        
        onOpenConfigureRequested: root.openConfigureRequested()
        onRequestOpenFolder: (folder) => {
            folderGrid.folder = folder;
            root.folderShown = true;
        }
        
        property real translateX: 0
        transform: Translate { x: favoritesGrid.translateX }
        visible: opacity !== 0
    }
 
    FolderGrid {
        id: folderGrid
        anchors.fill: parent
        folder: null 
        
        interactive: root.interactive
        
        cellWidth: root.cellWidth
        cellHeight: root.cellHeight
        
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin
        twoColumn: root.twoColumn
        
        onOpenConfigureRequested: root.openConfigureRequested()
        onCloseRequested: root.folderShown = false
        
        property real translateX: 0
        transform: Translate { x: folderGrid.translateX }
        opacity: 0
        visible: opacity !== 0
    }
    
    SequentialAnimation {
        id: openFolderAnim
        
        ParallelAnimation {
            NumberAnimation {
                target: favoritesGrid
                properties: 'translateX'
                duration: MobileShell.MobileShellSettings.animationsEnabled ? 200 : 0
                from: 0
                to: -PlasmaCore.Units.gridUnit
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: favoritesGrid
                properties: 'opacity'
                duration: MobileShell.MobileShellSettings.animationsEnabled ? 200 : 0
                from: 1
                to: 0
                easing.type: Easing.InOutQuad
            }
        }
        
        ParallelAnimation {
            NumberAnimation {
                target: folderGrid
                properties: 'translateX'
                duration: MobileShell.MobileShellSettings.animationsEnabled ? 200 : 0
                from: PlasmaCore.Units.gridUnit
                to: 0
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: folderGrid
                properties: 'opacity'
                duration: MobileShell.MobileShellSettings.animationsEnabled ? 200 : 0
                from: 0
                to: 1
                easing.type: Easing.InOutQuad
            }
        }
    }
    
    SequentialAnimation {
        id: closeFolderAnim
        
        ParallelAnimation {
            NumberAnimation {
                target: folderGrid
                properties: 'translateX'
                duration: MobileShell.MobileShellSettings.animationsEnabled ? 200 : 0
                from: 0
                to: PlasmaCore.Units.gridUnit
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: folderGrid
                properties: 'opacity'
                duration: MobileShell.MobileShellSettings.animationsEnabled ? 200 : 0
                from: 1
                to: 0
                easing.type: Easing.InOutQuad
            }
        }
        
        ParallelAnimation {
            NumberAnimation {
                target: favoritesGrid
                properties: 'translateX'
                duration: MobileShell.MobileShellSettings.animationsEnabled ? 200 : 0
                from: -PlasmaCore.Units.gridUnit
                to: 0
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: favoritesGrid
                properties: 'opacity'
                duration: MobileShell.MobileShellSettings.animationsEnabled ? 200 : 0
                from: 0
                to: 1
                easing.type: Easing.InOutQuad
            }
        }
    }
}
