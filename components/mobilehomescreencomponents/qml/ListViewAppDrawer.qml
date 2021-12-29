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

import "private"

AbstractAppDrawer {
    id: root
    
    contentItem: ListView {
        id: listView
        clip: true
        reuseItems: true
        cacheBuffer: model.count * delegateHeight // delegate height
        
        // start location of dragging
        property real startDragContentY
        onMovementStarted: {
            oldContentY = contentY;
            startDragContentY = contentY;
        }
        
        // move drawer down when at the top of the app list
        property real oldContentY
        property bool movingDrawerDown: false
        onContentYChanged: {
            let candidateContentY = root.flickable.contentY - (oldContentY - contentY);
            if (dragging && startDragContentY <= 0 && oldContentY <= 0 && candidateContentY <= root.drawerTopMargin) {
                root.flickable.contentY = candidateContentY;
                contentY = 0;
                movingDrawerDown = true;
            }
            oldContentY = contentY;
        }
        onMovementEnded: {
            if (movingDrawerDown) {
                root.snapDrawerStatus();
                movingDrawerDown = false;
            }
        }
        
        property int delegateHeight: PlasmaCore.Units.gridUnit * 3

        model: HomeScreenComponents.ApplicationListModel

        delegate: DrawerListDelegate {
            id: delegate
            
            width: listView.width
            height: listView.delegateHeight
            reservedSpaceForLabel: root.reservedSpaceForLabel

            onDragStarted: (imageSource, x, y, mimeData) => {
                root.Drag.imageSource = imageSource;
                root.Drag.hotSpot.x = x;
                root.Drag.hotSpot.y = y;
                root.Drag.mimeData = { "text/x-plasma-phone-homescreen-launcher": mimeData };

                root.close()

                root.dragStarted()
                root.Drag.active = true;
            }
            onLaunch: (x, y, icon, title, storageId) => {
                if (icon !== "") {
                    MobileShell.HomeScreenControls.openAppAnimation(
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
