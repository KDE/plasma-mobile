/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
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
