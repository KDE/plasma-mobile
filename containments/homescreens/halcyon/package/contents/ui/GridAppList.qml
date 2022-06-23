/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.10 as Kirigami

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen.halcyon 1.0 as Halcyon

GridView {
    id: gridView
    clip: true
    
    signal launched
    
    readonly property int reservedSpaceForLabel: metrics.height
    
    cellWidth: width / Math.min(Math.floor(width / (PlasmaCore.Units.iconSizes.huge + Kirigami.Units.largeSpacing * 2)), 8)
    cellHeight: cellWidth + reservedSpaceForLabel

    property int columns: Math.floor(width / cellWidth)
    property int rows: Math.ceil(model.count / columns)
    
    cacheBuffer: Math.max(0, rows * cellHeight)

    model: Halcyon.ApplicationListModel

    header: Controls.Control {
        implicitWidth: gridView.width
        topPadding: PlasmaCore.Units.largeSpacing
        bottomPadding: PlasmaCore.Units.largeSpacing
        leftPadding: PlasmaCore.Units.smallSpacing
        
        contentItem: PlasmaExtras.Heading {
            color: "white"
            level: 1
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
                MobileShell.HomeScreenControls.openAppLaunchAnimation(
                        icon,
                        title,
                        delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                        delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                        Math.min(delegate.iconItem.width, delegate.iconItem.height));
            }

            application.setMinimizedDelegate(delegate);
            application.runApplication();
            gridView.launched();
        }
    }
}