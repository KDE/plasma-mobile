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

import QtQuick 2.1
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: delegateItem
    property string className: findMimeType()
    property string genericClassName: findMimeType()
    implicitWidth: itemLoader.item ? itemLoader.item.implicitWidth : 0
    implicitHeight: itemLoader.item ? itemLoader.item.implicitHeight : 0
    signal clicked(variant mouse)
    signal pressed(variant mouse)
    signal released(variant mouse)
    signal pressAndHold(variant mouse)

    function findMimeType() {
        //TODO It should also find the bookmarks
        if (String(decoration).indexOf("image") >= 0) {
            return "Image"
        } else {
            return "FileDataObject"
        }
    }
    function roundToStandardSize(size)
    {
        if (size >= units.iconSizes.enormous) {
            return units.iconSizes.enormous
        } else if (size >= units.iconSizes.huge) {
            return units.iconSizes.huge
        } else if (size >= units.iconSizes.large) {
            return units.iconSizes.large
        } else if (size >= units.iconSizes.medium) {
            return units.iconSizes.medium
        } else if (size >= units.iconSizes.smallMedium) {
            return units.iconSizes.smallMedium
        } else {
            return units.iconSizes.small
        }
    }

    Loader {
        id: itemLoader
        anchors {
            fill: parent
            margins: 4
        }

        //FIXME: assuming the view is parent.parent is bad, it should have the view attached property (it appears it doesn't, why?)
        source: {
            if (!className && !genericClassName) {
                return ""
            }
            var view = delegateItem.parent

            if (view != undefined && view.orientation == undefined && view.flow == undefined) {
                view = view.parent
            }

            if (!delegateItem.parent || !delegateItem.parent.parent || view == undefined || view.orientation == ListView.Horizontal || view.cellHeight != undefined) {
                return Qt.resolvedUrl("resourcedelegates/" + className + "/ItemHorizontal.qml")
            } else {
                return Qt.resolvedUrl("resourcedelegates/" + className + "/Item.qml")
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: delegateItem.clicked(mouse)

        onPressed: delegateItem.pressed(mouse)
        onReleased: delegateItem.released(mouse)
        onPressAndHold: delegateItem.pressAndHold(mouse)
    }
}
