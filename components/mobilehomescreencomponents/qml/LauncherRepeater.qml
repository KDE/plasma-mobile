/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import QtGraphicalEffects 1.6

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.kirigami 2.14 as Kirigami
import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

Repeater {
    id: launcherRepeater
    model: HomeScreenComponents.FavoritesModel
    property ContainmentLayoutManager.AppletsLayout appletsLayout
    property FavoriteStrip favoriteStrip
    property int cellWidth
    property int cellHeight

    signal scrollLeftRequested
    signal scrollRightRequested
    signal stopScrollRequested

    delegate: HomeDelegate {
        id: delegate
        width: launcherRepeater.cellWidth
        height: Math.min(parent.height, launcherRepeater.cellHeight)
        appletsLayout: launcherRepeater.appletsLayout

        //just the normal inline binding in height: fails as it gets broken, make it explicit
        Binding {
            target: delegate
            property: "height"
            value: Math.min(delegate.parent.height, launcherRepeater.cellHeight)
        }
        parent: parentFromLocation
        reservedSpaceForLabel: metrics.height
        property Item parentFromLocation: {
            switch (model.applicationLocation) {
            case HomeScreenComponents.ApplicationListModel.Favorites:
                return favoriteStrip.flow;
            case HomeScreenComponents.ApplicationListModel.Desktop:
            default:
                return appletsLayout;
            }
        }
        Component.onCompleted: {
            if (model.applicationLocation === HomeScreenComponents.ApplicationListModel.Desktop) {
                appletsLayout.restoreItem(delegate);
            }
        }

        onUserDrag: {
            dragCenterX = dragCenter.x;
            dragCenterY = dragCenter.y;
            launcherDragManager.dragItem(delegate, dragCenter.x, dragCenter.y);

            delegate.width = appletsLayout.cellWidth;
            delegate.height = appletsLayout.cellHeight;

            var pos = plasmoid.fullRepresentationItem.mapFromItem(delegate, dragCenter.x, dragCenter.y);

            //SCROLL LEFT
            if (pos.x < PlasmaCore.Units.gridUnit) {
                launcherRepeater.scrollLeftRequested();
            //SCROLL RIGHT
            } else if (pos.x > mainFlickable.width - PlasmaCore.Units.gridUnit) {
                launcherRepeater.scrollRightRequested();
            //DON't SCROLL
            } else {
                launcherRepeater.stopScrollRequested();
            }
        }

        onDragActiveChanged: {
            launcherDragManager.active = dragActive
            if (dragActive) {
                // Must be 0, 0 as at this point dragCenterX and dragCenterY are on the drag before"
                launcherDragManager.startDrag(delegate);
                launcherDragManager.currentlyDraggedDelegate = delegate;
            } else {
                launcherDragManager.dropItem(delegate, dragCenterX, dragCenterY);
                plasmoid.editMode = false;
                editMode = false;
                launcherRepeater.stopScrollRequested();
                launcherDragManager.currentlyDraggedDelegate = null;
                forceActiveFocus();
            }
        }

        onLaunch: (x, y, icon, title) => {
            if (icon !== "") {
                print(delegate.iconItem)
                NanoShell.StartupFeedback.open(
                        icon,
                        title,
                        delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                        delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                        Math.min(delegate.iconItem.width, delegate.iconItem.height));
            }
            root.launched();
        }
        onParentFromLocationChanged: {
            if (!launcherDragManager.active && parent != parentFromLocation) {
                parent = parentFromLocation;
                if (model.applicationLocation === HomeScreenComponents.ApplicationListModel.Favorites) {
                    plasmoid.nativeInterface.stackBefore(delegate, parentFromLocation.children[index]);

                } else if (model.applicationLocation === HomeScreenComponents.ApplicationListModel.Grid) {
                    plasmoid.nativeInterface.stackBefore(delegate, parentFromLocation.children[Math.max(0, index - HomeScreenComponents.ApplicationListModel.favoriteCount)]);
                }
            }
        }
    }
}

