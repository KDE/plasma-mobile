/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

LauncherContainer {
    id: root

    readonly property int columns: Math.floor(root.flow.width / cellWidth)
    readonly property int cellWidth: root.flow.width / Math.floor(root.flow.width / ((availableCellHeight - reservedSpaceForLabel) + PlasmaCore.Units.smallSpacing*4))
    readonly property int cellHeight: availableCellHeight

    signal launched

    frame.width: width

    Repeater {
        parent: root.flow
        model: HomeScreenComponents.ApplicationListModel
        delegate: HomeDelegate {
            id: delegate
            width: root.cellWidth
            height: root.cellHeight

            parent: parentFromLocation
            property Item parentFromLocation: {
                switch (model.applicationLocation) {
                case HomeScreenComponents.ApplicationListModel.Desktop:
                    return appletsLayout;
                case HomeScreenComponents.ApplicationListModel.Favorites:
                    return favoriteStrip.flow;
                default:
                    return root.flow;
                }
            }
            Component.onCompleted: {
                if (model.applicationLocation === HomeScreenComponents.ApplicationListModel.Desktop) {
                    appletsLayout.restoreItem(delegate);
                }
            }
            onLaunch: (x, y, icon, title) => {
                if (icon !== "") {
                    MobileShell.HomeScreenControls.openAppAnimation(
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
}

