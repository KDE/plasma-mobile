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
import QtGraphicalEffects 1.6

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.phone.homescreen 1.0

ContainmentLayoutManager.ItemContainer {
    id: delegate

    z: dragActive ? 1 : 0

    property var modelData: typeof model !== "undefined" ? model : null

    Layout.minimumWidth: launcherGrid.cellWidth
    Layout.minimumHeight: launcherGrid.cellHeight

    opacity: dragActive ? 0.4 : 1

    key: model.ApplicationStorageIdRole
    property real dragCenterX
    property real dragCenterY

    editModeCondition: ContainmentLayoutManager.ItemContainer.AfterPressAndHold

    onDragActiveChanged: {
        launcherDragManager.active = dragActive
        if (dragActive) {
            // Must be 0, 0 as at this point dragCenterX and dragCenterY are on the drag before"
            launcherDragManager.startDrag(delegate);
            launcherDragManager.currentlyDraggedDelegate = delegate;
        } else {
            launcherDragManager.dropItem(delegate, dragCenterX, dragCenterY);
            plasmoid.editMode = false;
            editMode = false;
            plasmoid.fullRepresentationItem.stopScroll();
            launcherDragManager.currentlyDraggedDelegate = null;
        }
    }

    onUserDrag: {
        dragCenterX = dragCenter.x;
        dragCenterY = dragCenter.y;
        launcherDragManager.dragItem(delegate, dragCenter.x, dragCenter.y);

        delegate.width = launcherGrid.cellWidth;
        delegate.height = launcherGrid.cellHeight;

        var pos = plasmoid.fullRepresentationItem.mapFromItem(delegate, dragCenter.x, dragCenter.y);
        //SCROLL UP
        if (pos.y < plasmoid.availableScreenRect.y + units.gridUnit) {
            plasmoid.fullRepresentationItem.scrollUp();
        //SCROLL DOWN
        } else if (pos.y > plasmoid.availableScreenRect.y + plasmoid.availableScreenRect.height - units.gridUnit) {
            plasmoid.fullRepresentationItem.scrollDown();
        //DON't SCROLL
        } else {
            plasmoid.fullRepresentationItem.stopScroll();
        }
    }

    contentItem: MouseArea {
        onClicked: {
            clickFedbackAnimation.target = delegate;
            clickFedbackAnimation.running = true;
            feedbackWindow.title = modelData.ApplicationNameRole;
            feedbackWindow.icon = modelData.ApplicationIconRole;
            feedbackWindow.state = "open";

            plasmoid.nativeInterface.applicationListModel.runApplication(modelData.ApplicationStorageIdRole);
        }

        //preventStealing: true
        ColumnLayout {
            anchors {
                fill: parent
                leftMargin: units.smallSpacing * 2
                topMargin: units.smallSpacing * 2
                rightMargin: units.smallSpacing * 2
                bottomMargin: units.smallSpacing * 2
            }
            spacing: 0

            PlasmaCore.IconItem {
                id: icon

                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.fillWidth: true
                Layout.minimumHeight: parent.height - root.reservedSpaceForLabel
                Layout.preferredHeight: Layout.minimumHeight

                source: modelData ? modelData.ApplicationIconRole : ""
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
                Layout.leftMargin: -parent.anchors.leftMargin
                Layout.rightMargin: -parent.anchors.rightMargin
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                maximumLineCount: 2
                elide: Text.ElideRight

                text: {
                    var pieces = model.ApplicationNameRole.split(" ");
                    var word = "";
                    var nextWord = "";
                    var i = 0;
                    while (nextWord.length < 15) {
                        word += " " + pieces[i++];
                        if (i < pieces.length) {
                            nextWord = word + " " + pieces[i];
                        } else {
                            break;
                        }
                    }
                    return word;
                }
                //FIXME: export smallestReadableFont
                font.pixelSize: theme.defaultFont.pixelSize * 0.9
                color: model.ApplicationLocationRole == ApplicationListModel.Desktop ? "white" : theme.textColor

                layer.enabled: model.ApplicationLocationRole == ApplicationListModel.Desktop
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 8.0
                    samples: 16
                    color: Qt.rgba(0, 0, 0, 0.8)
                }
            }
        }
    }
}
