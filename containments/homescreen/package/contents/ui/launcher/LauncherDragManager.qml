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

import org.kde.phone.homescreen 1.0

Item {
    id: root

    property ContainmentLayoutManager.AppletsLayout appletsLayout
    property LauncherGrid launcherGrid
    property FavoriteStrip favoriteStrip
    property Delegate currentlyDraggedDelegate
    property bool active

    readonly property Item spacer: Item {
        width: launcherGrid.cellWidth
        height: launcherGrid.cellHeight
    }

    function startDrag(item) {
        internal.showSpacer(item, 0, 0);
    }

    function dragItem(delegate, dragCenterX, dragCenterY) {
              // newPosition
        var newRow = 0;

        var newContainer = internal.containerForItem(delegate, dragCenterX, dragCenterY);

        // Put it in the favorites strip
        if (newContainer == favoriteStrip) {
            var pos = favoriteStrip.flow.mapFromItem(delegate, 0, 0);
            newRow = Math.floor((pos.x + dragCenterX) / delegate.width);

            //plasmoid.nativeInterface.applicationListModel.setLocation(delegate.modelData.index, ApplicationListModel.Favorites);

            internal.showSpacer(delegate, dragCenterX, dragCenterY);
            plasmoid.nativeInterface.applicationListModel.moveItem(delegate.modelData.index, newRow);

        // Put it on desktop
        } else if (newContainer == appletsLayout) {
            var pos = appletsLayout.mapFromItem(delegate, 0, 0);
            //plasmoid.nativeInterface.applicationListModel.setLocation(delegate.modelData.index, ApplicationListModel.Desktop);

            internal.showSpacer(delegate, dragCenterX, dragCenterY);
            return;
    
        // Put it in the general view
        } else {
            var pos = launcherGrid.flow.mapFromItem(delegate, 0, 0);
            newRow = Math.floor(newContainer.flow.width / delegate.width) * Math.floor((pos.y + dragCenterY) / delegate.height) + Math.round((pos.x + dragCenterX) / delegate.width) + favoriteStrip.count;

            //plasmoid.nativeInterface.applicationListModel.setLocation(delegate.modelData.index, ApplicationListModel.Grid);

            internal.showSpacer(delegate, dragCenterX, dragCenterY);
            plasmoid.nativeInterface.applicationListModel.moveItem(delegate.modelData.index, newRow);
        }
    }

    function dropItem(item, dragCenterX, dragCenterY) {
        internal.positionItem(item, dragCenterX, dragCenterY);
    }

    // Those should never be accessed from outside
    QtObject {
        id: internal
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
            if (favoriteStrip.contains(Qt.point(0,favoriteStrip.frame.mapFromItem(item, dragCenterX, dragCenterY).y))
                && plasmoid.nativeInterface.applicationListModel.favoriteCount < plasmoid.nativeInterface.applicationListModel.maxFavoriteCount) {
                return favoriteStrip;
            } else if (appletsLayout.contains(appletsLayout.mapFromItem(item, dragCenterX, dragCenterY))) {
                return appletsLayout;
            } else {
                return launcherGrid;
            }
        }

        function putItemInDragSpace(item) {
            var pos = root.mapFromItem(item, 0, 0);
            item.parent = root;

            item.x = pos.x;
            item.y = pos.y;
        }

        function putInContainerLayout(item, container) {
            var pos = container.flow.mapFromItem(item, 0, 0);

            if (container == appletsLayout) {
                item.parent = container;
            } else {
                item.parent = container.flow;
            }

            item.x = pos.x;
            item.y = pos.y;
        }

        function nearestChild(item, dragCenterX, dragCenterY, container) {
            var distance = Number.POSITIVE_INFINITY;
            var child;
            var pos = container.flow.mapFromItem(item, dragCenterX, dragCenterY);

            // Search Right
            for (var i = 0; i < item.width * 2; i += item.width/2) {
                var candidate = container.flow.childAt(
                    Math.min(container.flow.width, Math.max(0, pos.x + i)),
                    Math.min(container.flow.height-1, Math.max(0, pos.y)));
                if (candidate && i < distance) {
                    child = candidate;
                    break;
                }
            }

            // Search Left
            for (var i = 0; i < item.width * 2; i += item.width/2) {
                var candidate = container.flow.childAt(Math.min(container.flow.width, Math.max(0, pos.x - i)), Math.min(container.flow.height-1, Math.max(0, pos.y)));
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

            appletsLayout.hidePlaceHolder();

            if (container == appletsLayout) {
                spacer.visible = false;
                appletsLayout.releaseSpace(item);
                putItemInDragSpace(item);
                var pos = appletsLayout.mapFromItem(item, 0, 0);
                appletsLayout.showPlaceHolderAt(Qt.rect(pos.x, pos.y, item.width, item.height));
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

            var pos = container.flow.mapFromItem(item, dragCenterX, dragCenterY);

            if (pos.x < child.x + child.width / 2) {
                plasmoid.nativeInterface.stackBefore(spacer, child);
            } else {
                plasmoid.nativeInterface.stackAfter(spacer, child);
            }

            putItemInDragSpace(item);

            spacer.visible = true;
        }

        function positionItem(item, dragCenterX, dragCenterY) {
            var container = containerForItem(item, dragCenterX, dragCenterY);

            raiseContainer(container);

            if (container == appletsLayout) {
                plasmoid.nativeInterface.applicationListModel.setLocation(item.modelData.index, ApplicationListModel.Desktop);
                var pos = appletsLayout.mapFromItem(item, 0, 0);
                item.parent = appletsLayout;
                item.x = pos.x;
                item.y = pos.y;
                appletsLayout.hidePlaceHolder();
                appletsLayout.positionItem(item);
                
                return;
            } else if (container == favoriteStrip) {
                plasmoid.nativeInterface.applicationListModel.setLocation(item.modelData.index, ApplicationListModel.Favorites);
            } else {
                plasmoid.nativeInterface.applicationListModel.setLocation(item.modelData.index, ApplicationListModel.Grid);
            }

            var child = nearestChild(item, dragCenterX, dragCenterY, container);

            putInContainerLayout(item, container);
            plasmoid.nativeInterface.stackBefore(item, spacer);
            spacer.visible = false;
            spacer.parent = container;
        }
    }
}


