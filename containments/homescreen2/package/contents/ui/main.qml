/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
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

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

Item {
    id: root
    width: 640
    height: 480

    property Item toolBox

    DragDrop.DropArea {
        anchors.fill: parent

        //TODO type safety?
        property Item appletsArea
        onDragEnter: {
            event.accept(event.proposedAction);
        }
        onDragMove: {
            appletsLayout.showPlaceHolderAt(
                Qt.rect(event.x - appletsLayout.defaultItemWidth / 2,
                event.y - appletsLayout.defaultItemHeight / 2,
                appletsLayout.defaultItemWidth,
                appletsLayout.defaultItemHeight)
            );
        }

        onDragLeave: {
            appletsLayout.hidePlaceHolder();
        }

        preventStealing: true

        onDrop: {
            plasmoid.processMimeData(event.mimeData,
                        event.x - appletsLayout.placeHolder.width / 2, event.y - appletsLayout.placeHolder.height / 2);
            event.accept(event.proposedAction);
            appletsLayout.hidePlaceHolder();
        }

Text {
    text:"Edit Mode"
    color: "white"
    visible: appletsLayout.editMode
}
        Connections {
            target: plasmoid
            onEditModeChanged: appletsLayout.editMode = plasmoid.editMode
        }

        ContainmentLayoutManager.AppletsLayout {
            id: appletsLayout
            anchors.fill: parent
            configKey: width > height ? "ItemGeometries" : "ItemGeometriesVertical"
            containment: plasmoid
            editModeCondition: plasmoid.immutable
                    ? ContainmentLayoutManager.AppletsLayout.Manual
                    : ContainmentLayoutManager.AppletsLayout.AfterPressAndHold

            // Sets the containment in edit mode when we go in edit mode as well
            onEditModeChanged: plasmoid.editMode = editMode

            minimumItemWidth: units.gridUnit * 3
            minimumItemHeight: minimumItemWidth

            defaultItemWidth: units.gridUnit * 6
            defaultItemHeight: defaultItemWidth

            cellWidth: units.iconSizes.small
            cellHeight: cellWidth

            acceptsAppletCallback: function(applet, x, y) {
                print("Applet: "+applet+" "+x+" "+y)
                return true;
            }

            appletContainerComponent: ContainmentLayoutManager.BasicAppletContainer {
                id: appletContainer
                configOverlayComponent: ConfigOverlay {}
            }

            placeHolder: ContainmentLayoutManager.PlaceHolder {}

            Repeater {
                model: 3
                ContainmentLayoutManager.ItemContainer {
                    id: extraIcon
                    key: "Icon-" + modelData
                    preferredLayoutDirection: editMode ? ContainmentLayoutManager.AppletsLayout.Closest : ContainmentLayoutManager.AppletsLayout.TopToBottom
                    x: 16
                    y: 16
                    implicitWidth: 48
                    implicitHeight: 48
                    
                    editModeCondition: ContainmentLayoutManager.ItemContainer.AfterPress

                    Rectangle {
                        anchors.fill: parent
                        color: extraIcon.focus ? "green" : "red"
                        radius: width
                        opacity: extraIcon.editMode ? 0.6 : 1
                    }
                }
            }
        }
    }
}
