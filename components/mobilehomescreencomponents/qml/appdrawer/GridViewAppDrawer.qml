/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.extras 2.0 as PlasmaExtra
import org.kde.kirigami 2.10 as Kirigami

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

import "../private"

AbstractAppDrawer {
    id: root
    
    contentItem: GridView {
        id: gridView
        clip: true
        interactive: root.homeScreenState.appDrawerInteractive
        
        cellWidth: root.contentWidth / Math.floor(root.contentWidth / ((root.availableCellHeight - root.reservedSpaceForLabel) + PlasmaCore.Units.smallSpacing*4))
        cellHeight: root.availableCellHeight

        property int columns: Math.floor(root.contentWidth / cellWidth)
        property int rows: Math.ceil(model.count / columns)
        
        cacheBuffer: Math.max(0, rows * cellHeight)

        model: HomeScreenComponents.ApplicationListModel

        delegate: DrawerGridDelegate {
            id: delegate
            
            width: gridView.cellWidth
            height: gridView.cellHeight
            reservedSpaceForLabel: root.reservedSpaceForLabel

            onDragStarted: (imageSource, x, y, mimeData) => {
                root.Drag.imageSource = imageSource;
                root.Drag.hotSpot.x = x;
                root.Drag.hotSpot.y = y;
                root.Drag.mimeData = { "text/x-plasma-phone-homescreen-launcher": mimeData };

                root.homeScreenState.closeAppDrawer()

                root.dragStarted()
                root.Drag.active = true;
            }
            onLaunch: (x, y, icon, title, storageId) => {
                if (icon !== "") {
                    MobileShell.HomeScreenControls.openAppLaunchAnimation(
                            icon,
                            title,
                            delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                            delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                            Math.min(delegate.iconItem.width, delegate.iconItem.height));
                }

                HomeScreenComponents.ApplicationListModel.setMinimizedDelegate(index, delegate);
                HomeScreenComponents.ApplicationListModel.runApplication(storageId);
                root.launched();
            }
        }

        PC3.ScrollBar.vertical: PC3.ScrollBar {
            id: scrollBar
            interactive: true
            enabled: true
            Behavior on opacity {
                OpacityAnimator {
                    duration: PlasmaCore.Units.longDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }
            implicitWidth: PlasmaCore.Units.smallSpacing
            contentItem: Rectangle {
                radius: width/2
                color: Qt.rgba(1, 1, 1, 0.3)
            }
        }
    }
}

