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

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

LauncherContainer {
    id: root

    readonly property bool dragging: root.flow.dragData
    property bool reorderingApps: false


    readonly property int cellWidth: root.flow.width / Math.floor(root.flow.width / ((availableCellHeight - reservedSpaceForLabel) + units.smallSpacing*4))
    readonly property int cellHeight: availableCellHeight - topPadding


    Repeater {
        model: plasmoid.nativeInterface.applicationListModel
        delegate: Delegate {
            id: delegate
            width: root.cellWidth
            height: root.cellHeight

            parent: {
                if (model.ApplicationOnDesktopRole) {
                    return appletsLayout;
                }
                if (model.ApplicationFavoriteRole) {
                    if (editMode) {
                        return favoriteStrip.contentItem;
                    } else {
                        return favoriteStrip.flow;
                    }
                }
                if (editMode) {
                    return flowParent;
                } else {
                    return root.flow;
                }
            }
        }
    }
}

