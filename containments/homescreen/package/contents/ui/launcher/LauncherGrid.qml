/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.plasma.private.nanoshell 2.0 as NanoShell

import org.kde.phone.homescreen 1.0

LauncherContainer {
    id: root

    readonly property int columns: Math.floor(root.flow.width / cellWidth)
    readonly property int cellWidth: root.flow.width / Math.floor(root.flow.width / ((availableCellHeight - reservedSpaceForLabel) + units.smallSpacing*4))
    readonly property int cellHeight: availableCellHeight

    signal launched

    frame.width: width

    Repeater {
        parent: root.flow
        model: plasmoid.nativeInterface.applicationListModel
        delegate: HomeDelegate {
            id: delegate
            width: root.cellWidth
            height: root.cellHeight

            parent: parentFromLocation
            property Item parentFromLocation: {
                switch (model.applicationLocation) {
                case ApplicationListModel.Desktop:
                    return appletsLayout;
                case ApplicationListModel.Favorites:
                    return favoriteStrip.flow;
                default:
                    return root.flow;
                }
            }
            Component.onCompleted: {
                if (model.applicationLocation === ApplicationListModel.Desktop) {
                    appletsLayout.restoreItem(delegate);
                }
            }
            onLaunch: (x, y, icon, title) => {
                if (icon !== "") {
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
                    if (model.applicationLocation === ApplicationListModel.Favorites) {
                        plasmoid.nativeInterface.stackBefore(delegate, parentFromLocation.children[index]);

                    } else if (model.applicationLocation === ApplicationListModel.Grid) {
                        plasmoid.nativeInterface.stackBefore(delegate, parentFromLocation.children[Math.max(0, index - plasmoid.nativeInterface.applicationListModel.favoriteCount)]);
                    }
                }
            }
        }
    }
}

