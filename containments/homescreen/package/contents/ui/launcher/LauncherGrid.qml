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

import org.kde.phone.homescreen 1.0

LauncherContainer {
    id: root

    readonly property int columns: Math.floor(root.flow.width / cellWidth)
    readonly property int cellWidth: root.flow.width / Math.floor(root.flow.width / ((availableCellHeight - reservedSpaceForLabel) + units.smallSpacing*4))
    readonly property int cellHeight: availableCellHeight
    launcherGrid: root

    frame.width: width

    PlasmaCore.IconItem {
        id: effect
        height: 64
        width:  64
        visible: false
        x: 0
        y: 0

        source: "pattern-kde"
        property string title

        SequentialAnimation {
            id: woosh
            ScriptAction {
                script: effect.visible = true
            }
            ParallelAnimation {
                NumberAnimation {
                    target: effect
                    property: "opacity"
                    from: 0.9
                    to: 0
                    duration: 200
                }
                NumberAnimation {
                    target: effect
                    property: "scale"
                    from: 1
                    to: 3
                    duration: 200
                }
            }
            ScriptAction {
                script: {
                    feedbackWindow.title = effect.title
                    feedbackWindow.icon = effect.source
                    feedbackWindow.state = "open"
                    effect.visible = false
                }
            }
        }

        function swoosh(x, y, sauce, title) {
            effect.x = x
            effect.y = y
            effect.source = sauce
            effect.visible = true
            effect.title = title
            woosh.restart()
        }
    }

    Repeater {
        parent: root.flow
        model: plasmoid.nativeInterface.applicationListModel
        delegate: Delegate {
            id: delegate
            width: root.cellWidth
            height: root.cellHeight

            parent: parentFromLocation
            property Item parentFromLocation: {
                switch (model.ApplicationLocationRole) {
                case ApplicationListModel.Desktop:
                    return appletsLayout;
                case ApplicationListModel.Favorites:
                    return favoriteStrip.flow;
                default:
                    return root.flow;
                }
            }
            Component.onCompleted: {
                if (model.ApplicationLocationRole == ApplicationListModel.Desktop) {
                    appletsLayout.restoreItem(delegate);
                }
            }
            onLaunch: (a, b, c, d) => {
                print(a,b,c,d)
                effect.swoosh(a, b, c, d)
            }
            onParentFromLocationChanged: {
                if (!launcherDragManager.active && parent != parentFromLocation) {
                    parent = parentFromLocation;
                    if (model.ApplicationLocationRole == ApplicationListModel.Favorites) {
                        plasmoid.nativeInterface.stackBefore(delegate, parentFromLocation.children[index]);

                    } else if (model.ApplicationLocationRole == ApplicationListModel.Grid) {
                        plasmoid.nativeInterface.stackBefore(delegate, parentFromLocation.children[Math.max(0, index - plasmoid.nativeInterface.applicationListModel.favoriteCount)]);
                    }
                }
            }
        }
    }
}

