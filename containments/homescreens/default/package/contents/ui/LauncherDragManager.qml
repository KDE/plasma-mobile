/*
 *   SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.4

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root

    property ContainmentLayoutManager.AppletsLayout appletsLayout
    property FavoriteStrip favoriteStrip
    property ContainmentLayoutManager.ItemContainer currentlyDraggedDelegate
    property bool active
    property QtObject model: MobileShell.ApplicationListModel

    readonly property Item spacer: Item {
        width: favoriteStrip.cellWidth
        height: favoriteStrip.cellHeight
    }

    function startDrag(item) {
        showSpacer(item, 0, 0);
    }

    function dragItem(delegate, dragCenterX, dragCenterY) {
              // newPosition
        var newRow = 0;

        var newContainer = internal.containerForItem(delegate, dragCenterX, dragCenterY);
        if (!newContainer) {
            newContainer = appletsLayout;
        }

        // Put it in the favorites strip
        if (newContainer == favoriteStrip) {
            var pos = favoriteStrip.flow.mapFromItem(delegate, 0, 0);
            newRow = Math.floor((pos.x + dragCenterX) / delegate.width);

            //root.model.setLocation(delegate.modelData.index, MobileShell.ApplicationListModel.Favorites);

            showSpacer(delegate, dragCenterX, dragCenterY);
            root.model.moveItem(delegate.modelData.index, newRow);

        // Put it on desktop
        } else {
            var pos = appletsLayout.mapFromItem(delegate, 0, 0);
            //root.model.setLocation(delegate.modelData.index, MobileShell.ApplicationListModel.Desktop);

            showSpacer(delegate, dragCenterX, dragCenterY);
            return;
    
        }
    }

    function dropItem(item, dragCenterX, dragCenterY) {
        internal.positionItem(item, dragCenterX, dragCenterY);
    }

    function showSpacer(item, dragCenterX, dragCenterY) {
        var container = internal.containerForItem(item, dragCenterX, dragCenterY);

        internal.raiseContainer(container);

        appletsLayout.hidePlaceHolder();

        if (container == appletsLayout) {
            spacer.visible = false;
            spacer.parent = root;
            appletsLayout.releaseSpace(item);
            internal.putItemInDragSpace(item);
            var pos = appletsLayout.mapFromItem(item, 0, 0);
            appletsLayout.showPlaceHolderAt(Qt.rect(pos.x, pos.y, item.width, item.height));
            return;
        }

        var child = internal.nearestChild(item, dragCenterX, dragCenterY, container);

        if (!child) {
            spacer.visible = false;
            spacer.parent = container.flow
            spacer.visible = true;
            return;
        }

        spacer.visible = false;
        spacer.parent = container.flow

        var pos = container.flow.mapFromItem(item, dragCenterX, dragCenterY);

        if (pos.x < child.x + child.width / 2) {
            MobileShell.ShellUtil.stackItemBefore(spacer, child);
        } else {
            MobileShell.ShellUtil.stackItemAfter(spacer, child);
        }

        internal.putItemInDragSpace(item);

        spacer.visible = true;
    }

    function showSpacerAtPos(x, y, container) {
        var pos = container.flow.mapFromGlobal(x, y);
        internal.raiseContainer(container);

        appletsLayout.hidePlaceHolder();

        if (container == appletsLayout) {
            spacer.visible = false;
            spacer.parent = root;
            appletsLayout.showPlaceHolderAt(Qt.rect(pos.x, pos.y, appletsLayout.cellWidth, appletsLayout.cellHeight));
            return;
        }

        var child = internal.nearestChildFromPos(x, y, container);

        if (!child) {
            spacer.visible = false;
            spacer.parent = container.flow
            spacer.visible = true;
            return;
        }

        spacer.visible = false;
        spacer.parent = container.flow

        if (pos.x < child.x + child.width / 2) {
            MobileShell.ShellUtil.stackItemBefore(spacer, child);
        } else {
            MobileShell.ShellUtil.stackItemAfter(spacer, child);
        }

        spacer.visible = true;
    }

    function hideSpacer () {
        spacer.visible = false;
        spacer.parent = root;
    }

    // Those should never be accessed from outside
    QtObject {
        id: internal
        function raiseContainer(container) {
            container.z = 1;

            if (container == appletsLayout) {
                favoriteStrip.z = 0;
            } else if (container == favoriteStrip) {
                appletsLayout.z = 0;
            } else {
                appletsLayout.z = 0;
                favoriteStrip.z = 0;
            } 
        }

        function containerForItem(item, dragCenterX, dragCenterY) {
            if (!item.modelData) {
                return appletsLayout;
            } else if (favoriteStrip.contains(Qt.point(0,favoriteStrip.frame.mapFromItem(item, dragCenterX, dragCenterY).y))
                && (item.modelData.applicationLocation == MobileShell.ApplicationListModel.Favorites
                    || root.model.favoriteCount < root.model.maxFavoriteCount)) {
                return favoriteStrip;
            } else {
                return appletsLayout;
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


        function nearestChildFromPos(x, y, container) {
            var distance = Number.POSITIVE_INFINITY;
            var child;
            var pos = container.flow.mapFromGlobal(x, y);
    
            // Search Right
            for (var i = 0; i < appletsLayout.cellWidth * 2; i += appletsLayout.cellWidth/2) {
                var candidate = container.flow.childAt(
                    Math.min(container.flow.width, Math.max(0, pos.x + i)),
                    Math.min(container.flow.height-1, Math.max(0, pos.y)));

                if (candidate && i < distance) {
                    child = candidate;
                    break;
                }
            }

            // Search Left
            for (var i = 0; i < appletsLayout.cellWidth * 2; i += appletsLayout.cellWidth/2) {
                var candidate = container.flow.childAt(Math.min(container.flow.width, Math.max(0, pos.x - i)), Math.min(container.flow.height-1, Math.max(0, pos.y)));

                if (candidate && i < distance) {
                    child = candidate;
                    break;
                }
            }

            if (!child) {
               /* if (item.y < container.flow.height/2) {
                    child = container.flow.children[0];
                } else {
                    child = container.flow.children[container.flow.children.length - 1];
                }*/
            }

            return child;
        }


        function positionItem(item, dragCenterX, dragCenterY) {
            hideSpacer();
            var container = containerForItem(item, dragCenterX, dragCenterY);

            raiseContainer(container);

            if (container == appletsLayout) {
                if (item.modelData) {
                    root.model.setLocation(item.modelData.index, MobileShell.ApplicationListModel.Desktop);
                }
                var pos = appletsLayout.mapFromItem(item, 0, 0);
                item.parent = appletsLayout;
                item.x = pos.x;
                item.y = pos.y;
                appletsLayout.hidePlaceHolder();
                appletsLayout.positionItem(item);
                
                return;
            } else if (container == favoriteStrip) {
                root.model.setLocation(item.modelData.index, MobileShell.ApplicationListModel.Favorites);
            } else {
                root.model.setLocation(item.modelData.index, MobileShell.ApplicationListModel.Grid);
            }

            var child = nearestChild(item, dragCenterX, dragCenterY, container);

            putInContainerLayout(item, container);
            MobileShell.ShellUtil.stackItemBefore(item, spacer);
            spacer.visible = false;
            spacer.parent = root;
        }
    }
}


