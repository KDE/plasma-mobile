// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Window 2.2

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

/**
 * Root element that contains all the ActionDrawer's contents, and is anchored to the screen.
 */
Item {
    id: root

    required property var actionDrawer

    // pinned position (disabled when openToPinnedMode is false)
    readonly property real minimizedQuickSettingsOffset: quickSettingsDrawer.minimizedHeight

    // fully open position
    readonly property real maximizedQuickSettingsOffset: minimizedQuickSettingsOffset + quickSettingsDrawer.maxAddedHeight

    property alias quickSettings: quickSettingsDrawer.quickSettings
    property alias statusBar: quickSettingsDrawer.statusBar
    property alias mediaControlsWidget: quickSettingsDrawer.mediaControlsWidget

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    function applyMinMax(val) {
        return Math.max(0, Math.min(1, val));
    }

    MobileShell.QuickSettingsDrawer {
        id: quickSettingsDrawer

        // physically move the drawer when between closed <-> pinned mode
        readonly property real offsetHeight: actionDrawer.openToPinnedMode ? minimizedQuickSettingsOffset : maximizedQuickSettingsOffset
        anchors {
            topMargin: Math.min(root.actionDrawer.offsetResistance - offsetHeight, 0)
            top: parent.top
            left: parent.left
            right: parent.right
        }

        actionDrawer: root.actionDrawer

        // opacity and move animation (disabled when openToPinnedMode is false)
        property real offsetDist: actionDrawer.offsetResistance - minimizedQuickSettingsOffset
        property real totalOffsetDist: maximizedQuickSettingsOffset - minimizedQuickSettingsOffset
        minimizedToFullProgress: actionDrawer.openToPinnedMode ? (actionDrawer.opened ? applyMinMax(offsetDist / totalOffsetDist) : 0) : 1

        // this drawer opens in two stages when pinned mode is enabled:
        // ---
        // stage 1: the transform effect is used, the drawer physically moves down to the pinned mode
        // stage 2: the rectangle increases height to reveal content, but the content stays still
        // when pinned mode is disabled, only stage 1 happens

        // increase height of drawer when between pinned mode <-> maximized mode
        addedHeight: {
            if (!actionDrawer.openToPinnedMode) {
                // if pinned mode disabled, just go to full height
                return Math.max(maximizedQuickSettingsOffset - minimizedQuickSettingsOffset, root.actionDrawer.offsetResistance - minimizedQuickSettingsOffset)
            } else if (!actionDrawer.opened) {
                return Math.max(0, root.actionDrawer.offsetResistance - minimizedQuickSettingsOffset)
            } else {
                return Math.max(0, root.actionDrawer.offsetResistance - minimizedQuickSettingsOffset)
            }
        }
    }
}
