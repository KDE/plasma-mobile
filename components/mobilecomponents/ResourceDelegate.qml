/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: delegateItem
    property string className: model["className"] ? model["className"] : "FileDataObject"
    property string genericClassName: model["genericClassName"] ? model["genericClassName"] : "FileDataObject"

    property bool infoLabelVisible
    implicitWidth: itemLoader.item.implicitWidth
    implicitHeight: itemLoader.item.implicitHeight

    signal clicked(variant mouse)
    signal pressed(variant mouse)
    signal released(variant mouse)
    signal pressAndHold(variant mouse)

    function roundToStandardSize(size)
    {
        if (size >= theme.enormousIconSize) {
            return theme.enormousIconSize
        } else if (size >= theme.hugeIconSize) {
            return theme.hugeIconSize
        } else if (size >= theme.largeIconSize) {
            return theme.largeIconSize
        } else if (size >= theme.mediumIconSize) {
            return theme.mediumIconSize
        } else if (size >= theme.smallMediumIconSize) {
            return theme.smallMediumIconSize
        } else {
            return theme.smallIconSize
        }
    }

    MobileComponents.FallbackComponent {
        id: fallback
    }

    Loader {
        id: itemLoader
        anchors {
            fill: parent
            margins: 4
        }

        //FIXME: assuming the view is parent.parent is bad, it should have the view attached property (it appears it doesnt, why?)
        source: {
            var view = delegateItem.parent

            if (view != undefined && view.orientation == undefined && view.flow == undefined) {
                view = view.parent
            }
            if (view != undefined && view.orientation == undefined && view.flow == undefined) {
                view = view.parent
            }

            if (!delegateItem.parent || !delegateItem.parent.parent || view == undefined || view.orientation == ListView.Horizontal || view.cellHeight != undefined) {
                return fallback.resolvePath("resourcedelegates", [(className + "/ItemHorizontal.qml"), (genericClassName + "/ItemHorizontal.qml"), "FileDataObject/ItemHorizontal.qml"])
            } else {
                return fallback.resolvePath("resourcedelegates", [(className + "/Item.qml"), (genericClassName + "/Item.qml"), "FileDataObject/Item.qml"])
            }
        }
    }

    //FIXME: this mess is due to mousearea not having screen coordinates
    MobileComponents.MouseEventListener {
        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            onClicked: delegateItem.clicked(mouse)

            onPressed: delegateItem.pressed(mouse)
            onReleased: delegateItem.released(mouse)
            onPressAndHold: {
                delegateItem.pressAndHold(mouse)
                if (resourceInstance && contextMenu) {
                    contextMenu.parentItem = delegateItem
                    contextMenu.adjustPosition();
                    contextMenu.visible = true
                }
            }
        }

        onPositionChanged: {
            if (contextMenu) {
                contextMenu.mainItem.highlightItem(mouse.screenX, mouse.screenY)
            }
        }

        onReleased: {
            if (contextMenu) {
                contextMenu.mainItem.runItem(mouse.screenX, mouse.screenY)
            }
        }
    }
}
