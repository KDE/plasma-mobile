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

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12

import org.kde.plasma.core 2.0 as PlasmaCore

DrawerBackground {
    id: fullContainer
    property Item applet
    property ObjectModel fullRepresentationModel
    property ListView fullRepresentationView
    visible: shouldBeVisible
    property bool shouldBeVisible: applet && (applet.status != PlasmaCore.Types.HiddenStatus && applet.status != PlasmaCore.Types.PassiveStatus)
    height: parent.height
    width: visible ? quickSettingsParent.width : 0
    Layout.minimumHeight: applet && applet.switchHeight
    onShouldBeVisibleChanged: fullContainer.visible = fullContainer.shouldBeVisible

    Component.onCompleted: visibleChanged();
    onVisibleChanged: {
        if (visible) {
            for (var i = 0; i < fullRepresentationModel.count; ++i) {
                if (fullRepresentationModel.get(i) === this) {
                    return;
                }
            }
            fullRepresentationModel.append(this);
            fullRepresentationView.forceLayout();

            fullRepresentationView.currentIndex = ObjectModel.index;
            fullRepresentationView.positionViewAtIndex(ObjectModel.index, ListView.Contain)
        } else if (ObjectModel.index >= 0) {
            fullRepresentationModel.remove(ObjectModel.index);
            fullRepresentationView.forceLayout();
        }
        if (!shouldBeVisible) {
            visible = false;
        }
    }
    Connections {
        target: fullContainer.applet
        function onActivated() {
            if (!visible) {
                return;
            }
            fullRepresentationView.currentIndex = ObjectModel.index;
        }
    }
    Connections {
        target: fullContainer.applet.fullRepresentationItem
        function onParentChanged() {
            fullContainer.applet.fullRepresentationItem.parent = fullContainer;
        }
    }
}
