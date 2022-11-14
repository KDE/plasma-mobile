/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.10 as Kirigami

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

MobileShell.GridView {
    id: gridView
    cacheBuffer: cellHeight * 20 // 10 rows above and below
    reuseItems: true
    
    // ensure items aren't visible out of bounds
    layer.enabled: true
    
    readonly property int reservedSpaceForLabel: metrics.height
    readonly property real effectiveContentWidth: width - leftMargin - rightMargin
    
    cellWidth: gridView.effectiveContentWidth / Math.min(Math.floor(effectiveContentWidth / (PlasmaCore.Units.iconSizes.huge + Kirigami.Units.largeSpacing * 2)), 8)
    cellHeight: cellWidth + reservedSpaceForLabel

    property int columns: Math.floor(effectiveContentWidth / cellWidth)
    property int rows: Math.ceil(Halcyon.ApplicationListModel.count / columns)

    function goToBeginning() {
        goToBeginningAnim.restart();
    }
    
    NumberAnimation on contentY {
        id: goToBeginningAnim
        to: gridView.originY
        duration: 200
        easing.type: Easing.InOutQuad
    }
    
    model: Halcyon.ApplicationListModel

    header: MobileShell.BaseItem {
        implicitWidth: gridView.effectiveContentWidth
        topPadding: PlasmaCore.Units.largeSpacing + Math.round(gridView.height * 0.2)
        bottomPadding: PlasmaCore.Units.largeSpacing
        leftPadding: PlasmaCore.Units.smallSpacing
        
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
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 0.85
        font.weight: Font.Bold
    }
    
    delegate: GridAppDelegate {
        id: delegate
        
        property Halcyon.Application application: model.application
        
        width: gridView.cellWidth
        height: gridView.cellHeight
        reservedSpaceForLabel: gridView.reservedSpaceForLabel

        onLaunch: (x, y, icon, title, storageId) => {
            if (icon !== "") {
                MobileShellState.Shell.openAppLaunchAnimation(
                        icon,
                        title,
                        delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                        delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                        Math.min(delegate.iconItem.width, delegate.iconItem.height));
            }

            application.setMinimizedDelegate(delegate);
            MobileShell.ShellUtil.launchApp(application.storageId);
        }
    }
}
