/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami 2.10 as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import plasma.applet.org.kde.plasma.mobile.homescreen.halcyon as Halcyon
import org.kde.plasma.plasmoid

MobileShell.GridView {
    id: gridView
    cacheBuffer: cellHeight * 20 // 10 rows above and below
    reuseItems: true

    Controls.ScrollBar.vertical: Controls.ScrollBar {}

    Connections {
        target: parent

        function onFocusRequested() {
            forceActiveFocus();
        }
    }

    // ensure items aren't visible out of bounds
    layer.enabled: true

    readonly property int reservedSpaceForLabel: metrics.height
    readonly property real effectiveContentWidth: width - leftMargin - rightMargin

    cellWidth: gridView.effectiveContentWidth / Math.min(Math.floor(effectiveContentWidth / (Kirigami.Units.iconSizes.huge + Kirigami.Units.largeSpacing * 2)), 8)
    cellHeight: cellWidth + reservedSpaceForLabel

    property int columns: Math.floor(effectiveContentWidth / cellWidth)
    property int rows: Math.ceil(Halcyon.ApplicationListModel.count / columns)

    function goToBeginning() {
        goToBeginningAnim.restart();
    }

    NumberAnimation on contentY {
        id: goToBeginningAnim
        to: gridView.originY
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
    }

    model: Halcyon.ApplicationListModel

    header: MobileShell.BaseItem {
        implicitWidth: gridView.effectiveContentWidth
        topPadding: Kirigami.Units.gridUnit + Math.round(gridView.height * 0.1)
        bottomPadding: Kirigami.Units.gridUnit
        leftPadding: Kirigami.Units.smallSpacing

        contentItem: PC3.Label {
            color: "white"
            font.pointSize: 16
            font.weight: Font.Bold
            text: i18n("Applications")
        }
    }

    PC3.Label {
        id: metrics
        text: "M\nM"
        visible: false
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.85
        font.weight: Font.Bold
    }

    Keys.onReturnPressed: currentItem.launchApp()
    delegate: GridAppDelegate {
        id: delegate

        property Halcyon.Application application: model.application

        width: gridView.cellWidth
        height: gridView.cellHeight
        reservedSpaceForLabel: gridView.reservedSpaceForLabel

        onLaunch: (x, y, icon, title, storageId) => {
            if (icon !== "") {
                MobileShellState.ShellDBusClient.openAppLaunchAnimationWithPosition(
                    Plasmoid.screen,
                    icon,
                    title,
                    storageId,
                    delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                    delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                    Math.min(delegate.iconItem.width, delegate.iconItem.height));
            }

            application.setMinimizedDelegate(delegate);
            MobileShell.AppLaunch.launchOrActivateApp(application.storageId);
        }
    }

    Component.onCompleted: {
        goToBeginning();
    }
}
