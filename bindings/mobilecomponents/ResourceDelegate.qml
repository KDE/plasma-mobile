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
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Item {
    id: delegateItem
    property string resourceType
    property bool infoLabelVisible
    property int implicitWidth: itemLoader.item.implicitWidth
    property int implicitHeight: itemLoader.item.implicitHeight

    MobileComponents.FallbackComponent {
        id: fallback
    }

    Loader {
        id: itemLoader
        width: parent.width
        height: parent.height

        //FIXME: assuming the view is parent.parent is bad, it should have the view attached property (it appears it doesnt, why?
        source: {
                  if (delegateItem.parent.parent.orientation == ListView.Horizontal || delegateItem.view.cellHeight != undefined) {
                      return fallback.resolvePath("resourcedelegates", [(resourceType.split("#")[1] + "/ItemHorizontal.qml"), "FileDataObject/ItemHorizontal.qml"])
                  } else {
                      return fallback.resolvePath("resourcedelegates", [(resourceType.split("#")[1] + "/Item.qml"), "FileDataObject/Item.qml"])
                  }
                }

        MouseArea {
            anchors.fill: parent
            onPressAndHold: {
                //contextmenu code
            }
        }
    }
}
