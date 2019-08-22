/*
 *   Copyright 2019 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.4

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

QtObject {
    id: root

    property ContainmentLayoutManager.AppletsLayout appletsLayout
    property LauncherGrid launcherGrid
    property FavoriteStrip favoriteStrip

    readonly property Item spacer: Item {
        width: units.gridUnit * 4
        height: width
    }

    function raiseContainer(container) {
        container.z = 1;

        if (container == appletsLayout) {
            launcherGrid.z = 0;
            favoriteStrip.z = 0;
        } else if (container == favoriteStrip) {
            appletsLayout.z = 0;
            launcherGrid.z = 0;
        } else {
            appletsLayout.z = 0;
            favoriteStrip.z = 0;
        } 
    }

    function containerForItem(item, dragCenterX, dragCenterY) {
        if (favoriteStrip.contains(favoriteStrip.mapFromItem(item, dragCenterX, dragCenterY))) {
            return favoriteStrip;
        } else if (appletsLayout.contains(appletsLayout.mapFromItem(item, dragCenterX, dragCenterY))) {
            return appletsLayout;
        } else {
            return launcherGrid;
        }
    }

    function changeContainer(item, container) {
        var pos;
print("$$$$$$$$"+container)
        if (container == appletsLayout) {
            pos = container.mapFromItem(item, 0, 0);
            item.parent = container;
        } else {
            pos = container.contentItem.mapFromItem(item, 0, 0);
            item.parent = container.contentItem;
        }

        item.x = pos.x;
        item.y = pos.y;
    }

    function putInContainerLayout(item, container) {
        var pos = container.contentItem.mapFromItem(item, 0, 0);
print("££££££££££££££££"+container)
        if (container == appletsLayout) {
            item.parent = container;
        } else {
            item.parent = container.flow;
        }

        item.x = pos.x;
        item.y = pos.y;
    }

    function nearestChild (item, dragCenterX, dragCenterY, container) {
        var distance = Number.POSITIVE_INFINITY;
        var child;

        // Search Left
        for (var i = 0; i < item.width * 2; i += item.width/2) {
            var candidate = container.flow.childAt(
                Math.min(container.flow.width, Math.max(0, item.x + dragCenterX + i)),
                Math.min(container.flow.height-1, Math.max(0, item.y + dragCenterY)));
            if (candidate && i < distance) {
                child = candidate;
                break;
            }
        }

        // Search Right
        for (var i = 0; i < item.width * 2; i += item.width/2) {
            var candidate = container.flow.childAt(Math.min(container.flow.width, Math.max(0, item.x + dragCenterX - i)), Math.min(container.flow.height-1, Math.max(0, item.y + dragCenterY)));
            if (candidate && i < distance) {
                child = candidate;
                break;
            }
        }

        if (!child) {
            if (item.y < container.flow.height/2) {
                child = container.flow.children[0];
            } else {
                child = container.flow.children[container.flow.children.length - 1];
            }
        }

        return child;
    }

    function showSpacer(item, dragCenterX, dragCenterY) {
        var container = containerForItem(item, dragCenterX, dragCenterY);

        raiseContainer(container);
print("&&&&&&&&&&&"+container)
        if (container == appletsLayout) {
            spacer.visible = false;
            changeContainer(item, container);
            return;
        }

        var child = nearestChild(item, dragCenterX, dragCenterY, container);

        if (!child) {
            spacer.visible = false;
            spacer.parent = container.flow
            return;
        }

        spacer.visible = false;
        spacer.parent = container.flow

        if (item.x + dragCenterX < child.x + child.width / 2) {
            plasmoid.nativeInterface.stackBefore(spacer, child);
        } else {
            plasmoid.nativeInterface.stackAfter(spacer, child);
        }

        changeContainer(item, container);

        spacer.visible = true;
    }

    function positionItem(item, dragCenterX, dragCenterY) {
        var container = containerForItem(item, dragCenterX, dragCenterY);

        raiseContainer(container);

        if (container == appletsLayout) {
            return;
        }

        spacer.visible = false;
        spacer.parent = container.contentItem;

        var child = nearestChild(item, dragCenterX, dragCenterY, container);

        if (!child) {
            putInContainerLayout(item, container);
            return;
        }

        if (item.x + dragCenterX < child.x + child.width / 2) {
            putInContainerLayout(item, container);
            plasmoid.nativeInterface.stackBefore(item, child);
        } else {
            putInContainerLayout(item, container);
            plasmoid.nativeInterface.stackAfter(item, child);
        }
    }
}


