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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

ContainmentLayoutManager.ItemContainer {
    id: delegate

    z: dragging ? 1 : 0

    property var modelData: typeof model !== "undefined" ? model : null
    property ContainmentLayoutManager.ItemContainer beforeItem
    property Item container
    property ContainmentLayoutManager.ItemContainer before

    leftPadding: units.smallSpacing * 2
    topPadding: units.smallSpacing * 2
    rightPadding: units.smallSpacing * 2
    bottomPadding: units.smallSpacing * 2

    opacity: dragging ? 0.4 : 1

    editModeCondition: ContainmentLayoutManager.ItemContainer.AfterPressAndHold//model.ApplicationOnDesktopRole ? ContainmentLayoutManager.ItemContainer.AfterPressAndHold: ContainmentLayoutManager.ItemContainer.Manual
    onEditModeChanged: {//FIXME: remove
        plasmoid.editMode = editMode
        if (!editMode) {
            root.forceLayout();
        }
    }
    onDragActiveChanged: {
        if (dragActive) {
            if (container) {
                container.showSpacerBefore(delegate);
            }
            return;
        }
        
        plasmoid.editMode = false;
        editMode = false;
        if (container) {
            container.forceLayout();
            container.hideSpacer();
        }
    }

    onParentChanged: {
        if (container) {
            plasmoid.nativeInterface.orderItems(delegate, before);
        }
    }

    onUserDrag: {
       // newPosition
        var newRow = 0;

        // Put it in the favorites strip
        if (favoriteStrip.contains(favoriteStrip.mapFromItem(delegate, dragCenter.x, dragCenter.y))) {
            var pos = favoriteStrip.mapFromItem(delegate, 0, 0);
            newRow = Math.floor((pos.x + dragCenter.x) / delegate.width);
            before = favoriteStrip.flow.childAt(delegate.x + dragCenter.x, delegate.y + dragCenter.y);

            plasmoid.nativeInterface.applicationListModel.setFavoriteItem(index, true);


        // Put it on desktop
        } else if (appletsLayout.contains(appletsLayout.mapFromItem(delegate, dragCenter.x, dragCenter.y))) {
            var pos = appletsLayout.mapFromItem(delegate, 0, 0);
            plasmoid.nativeInterface.applicationListModel.setDesktopItem(index, true);
            delegate.x = pos.x
            delegate.y = pos.y
            before = null;
            return;
    
        // Put it in the general view
        } else {
            plasmoid.nativeInterface.applicationListModel.setFavoriteItem(index, false);
            plasmoid.nativeInterface.applicationListModel.setDesktopItem(index, false);

            newRow = Math.round(applicationsFlow.width / delegate.width) * Math.floor((delegate.y + dragCenter.y) / delegate.height) + Math.floor((delegate.x + dragCenter.x) / delegate.width) + favoriteStrip.count;
            before = applicationsFlow.childAt(delegate.x + dragCenter.x, delegate.y + dragCenter.y);
        }

        plasmoid.nativeInterface.applicationListModel.setDesktopItem(index, false);

        plasmoid.nativeInterface.applicationListModel.moveItem(modelData.index, newRow);

        if (container) {
            container.showSpacerBefore(before);
        }

        //delegate.x = newPosition.x;
    }

    contentItem: MouseArea {
        onClicked: {
            if (modelData.ApplicationStartupNotifyRole) {
                clickFedbackAnimation.target = delegate;
                clickFedbackAnimation.running = true;
                feedbackWindow.title = modelData.ApplicationNameRole;
                feedbackWindow.state = "open";
            }
            plasmoid.nativeInterface.applicationListModel.runApplication(modelData.ApplicationStorageIdRole);
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            PlasmaCore.IconItem {
                id: icon

                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height - root.reservedSpaceForLabel

                source: modelData ? modelData.ApplicationIconRole : ""
                scale: root.reorderingApps && dragDelegate && !dragging ? 0.6 : 1
                Behavior on scale {
                    NumberAnimation {
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            PlasmaComponents.Label {
                id: label
                visible: text.length > 0

                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                maximumLineCount: 2
                elide: Text.ElideRight

                text: modelData ? modelData.ApplicationNameRole : ""
                font.pixelSize: theme.defaultFont.pixelSize
                color: PlasmaCore.ColorScope.textColor
            }
        }
    }
}
