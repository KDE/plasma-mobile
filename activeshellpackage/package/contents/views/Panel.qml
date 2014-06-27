/*
 *  Copyright 2012 Marco Martin <mart@kde.org>
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

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore


PlasmaCore.FrameSvgItem {
    id: root
    width: 640
    height: 32
    imagePath: "widgets/panel-background"
    enabledBorders: PlasmaCore.FrameSvg.BottomBorder

    visible: true

    property Item containment

    onContainmentChanged: {
        print("New panel Containment: " + containment);
        containment.parent = containmentParent;
        containment.visible = true;
        containment.anchors.fill = containmentParent;
        containmentParent.anchors.bottomMargin = Math.min(root.margins.bottom, Math.max(1, root.height - units.iconSizes.smallMedium));
    }

    function minimumWidthChanged() {
        if (containment.formFactor === PlasmaCore.Types.Horizontal) {
            panel.width = Math.max(panel.width, containment.Layout.minimumWidth);
        }
    }
    function maximumWidthChanged() {
        if (containment.formFactor === PlasmaCore.Types.Horizontal) {
            panel.width = Math.min(panel.width, containment.Layout.maximumWidth);
        }
    }
    function preferredWidthChanged() {
        if (containment.formFactor === PlasmaCore.Types.Horizontal) {
            panel.width = Math.min(panel.maximumLength, Math.max(containment.Layout.preferredWidth, panel.minimumLength));
        }
    }

    function minimumHeightChanged() {
        if (containment.formFactor === PlasmaCore.Types.Vertical) {
            panel.height = Math.max(panel.height, containment.Layout.minimumWidth);
        }
    }
    function maximumHeightChanged() {
        if (containment.formFactor === PlasmaCore.Types.Vertical) {
            panel.height = Math.min(panel.height, containment.Layout.maximumWidth);
        }
    }
    function preferredHeightChanged() {
        if (containment.formFactor === PlasmaCore.Types.Vertical) {
            panel.height = Math.min(panel.maximumLength, Math.max(containment.Layout.preferredHeight, panel.minimumLength));
        }
    }

    Item {
        id: containmentParent
        anchors {
            fill: parent
            leftMargin: root.margins.left
            topMargin: root.margins.top
            rightMargin: root.margins.right
            bottomMargin: root.margins.bottom
        }
    }
}
