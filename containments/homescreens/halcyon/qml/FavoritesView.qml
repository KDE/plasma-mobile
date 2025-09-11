// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1
import QtQml.Models 2.15

import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

Item {
    id: root
    layer.enabled: true
    property MobileShell.MaskManager maskManager

    required property bool interactive
    required property var searchWidget

    readonly property real twoColumnThreshold: Kirigami.Units.gridUnit * 16
    readonly property bool twoColumn: root.width / 2 > twoColumnThreshold

    readonly property real cellWidth: twoColumn ? (root.width - leftMargin - rightMargin) / 2 : (root.width - leftMargin - rightMargin)
    readonly property real cellHeight: delegateHeight

    readonly property real leftMargin: Math.round(width * 0.1)
    readonly property real rightMargin: Math.round(width * 0.1)
    readonly property real delegateHeight: Math.round(Kirigami.Units.gridUnit * 3)

    property bool folderShown: false

    signal openConfigureRequested()
    signal pageForwardRequested();

    Connections {
        target: parent

        function onFocusRequested() {
            favoritesGrid.forceActiveFocus();
        }
    }

    function goToBeginning() {
        goToBeginningAnim.restart();
    }

    function closeFolder() {
        folderShown = false;
        closeFolderAnim.restart()
    }

    function openFolder() {
        folderShown = true;
        openFolderAnim.restart()
    }

    function resetHighlight() {
        favoritesGrid.currentIndex = -1;
    }

    FavoritesGrid {
        id: favoritesGrid

        property real openFolderProgress: 0
        anchors.fill: parent

        maskManager: root.maskManager
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
            root.openFolder();
        }

        property real translateX: openFolderProgress * -Kirigami.Units.gridUnit
        transform: Translate { x: favoritesGrid.translateX }
        opacity: 1 - openFolderProgress
        visible: opacity !== 0

        rightEdgeCallback: () => {
            pageForwardRequested();
        }
    }

    FolderGrid {
        id: folderGrid

        property real openProgress: 0
        anchors.fill: parent

        folder: null

        interactive: root.interactive

        cellWidth: root.cellWidth
        cellHeight: root.cellHeight

        leftMargin: root.leftMargin
        rightMargin: root.rightMargin
        twoColumn: root.twoColumn

        onOpenConfigureRequested: root.openConfigureRequested()
        onCloseRequested: root.closeFolder()

        property real translateX: (1 - openProgress) * Kirigami.Units.gridUnit
        transform: Translate { x: folderGrid.translateX }
        opacity: openProgress
        visible: opacity !== 0
    }

    // handle horizontal dragging in a folder
    DragHandler {
        id: dragHandler
        target: folderGrid
        enabled: folderGrid.visible

        yAxis.enabled: false
        xAxis.enabled: true
        grabPermissions: PointerHandler.TakeOverForbidden

        property real oldTranslationX
        property bool isClosing: false

        // when dragged
        onTranslationChanged: {
            let moveAmount = Math.max(0, translation.x) / (Kirigami.Units.gridUnit * 5);
            folderGrid.openProgress = 1 - Math.min(1, Math.max(0, moveAmount));
            isClosing = translation.x > oldTranslationX;
            oldTranslationX = translation.x;
        }

        // when drag is let go
        onActiveChanged: {
            if (!active) {
                isClosing ? closeFolder() : openFolder();
            }
        }
    }

    NumberAnimation {
        id: goToBeginningAnim
        target: favoritesGrid
        properties: 'contentY'
        to: favoritesGrid.originY
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
    }

    SequentialAnimation {
        id: openFolderAnim

        ParallelAnimation {
            NumberAnimation {
                target: favoritesGrid
                properties: 'openFolderProgress'
                duration: ShellSettings.Settings.animationsEnabled ? Kirigami.Units.longDuration : 0
                to: 1
                easing.type: Easing.InOutQuad
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: folderGrid
                properties: 'openProgress'
                duration: ShellSettings.Settings.animationsEnabled ? Kirigami.Units.longDuration : 0
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
                properties: 'openProgress'
                duration: ShellSettings.Settings.animationsEnabled ? Kirigami.Units.longDuration : 0
                to: 0
                easing.type: Easing.InOutQuad
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: favoritesGrid
                properties: 'openFolderProgress'
                duration: ShellSettings.Settings.animationsEnabled ? Kirigami.Units.longDuration : 0
                to: 0
                easing.type: Easing.InOutQuad
            }
        }
    }
}
