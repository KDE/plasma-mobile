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
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.phone.homescreen.default 1.0 as HomeScreenLib

import "../private"

AbstractAppDrawer {
    id: root
    
    contentItem: MobileShell.GridView {
        id: gridView
        clip: true
        
        /*
         * HACK: When the number of apps is less than the one that would fit in the first shown part of the drawer, make
         * this flickable interactive, in order to steal inputs that would normally be delivered to home.
         */
        interactive: contentHeight <= height ? true : root.homeScreenState.appDrawerInteractive
        
        readonly property real effectiveContentWidth: root.contentWidth - 2 * horizontalMargin
        readonly property real horizontalMargin: root.width * 0.1 / 2
        leftMargin: horizontalMargin
        rightMargin: horizontalMargin
        
        cellWidth: effectiveContentWidth / Math.min(Math.floor(effectiveContentWidth / (PlasmaCore.Units.iconSizes.huge + Kirigami.Units.largeSpacing * 2)), 8)
        cellHeight: cellWidth + root.reservedSpaceForLabel

        readonly property int columns: Math.floor(effectiveContentWidth / cellWidth)
        readonly property int rows: Math.ceil(gridView.count / columns)
        
        cacheBuffer: Math.max(0, rows * cellHeight)

        model: HomeScreenLib.ApplicationListModel

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
                    MobileShellState.Shell.openAppLaunchAnimation(
                            icon,
                            title,
                            delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                            delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                            Math.min(delegate.iconItem.width, delegate.iconItem.height));
                }

                HomeScreenLib.ApplicationListModel.setMinimizedDelegate(index, delegate);
                MobileShell.ShellUtil.launchApp(storageId);
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

