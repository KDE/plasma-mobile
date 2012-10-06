/*
 *   Copyright 2012 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

PlasmaCore.FrameSvgItem {
    id: root
    property alias text: titleLabel.text

    imagePath: "widgets/listitem"
    prefix: "section"

    anchors {
        left: parent.left
        right: parent.right
    }
    height: titleLabel.height + margins.top + margins.bottom
    PlasmaComponents.Label {
        id: titleLabel
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            //FIXME: why?
            topMargin: parent.margins.top
            leftMargin: parent.margins.left
            rightMargin: parent.margins.right
        }
    }
}
