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

Controls.Control {
    id: root

    property alias flow: applicationsFlow

    readonly property bool dragging: applicationsFlow.dragData
    property bool reorderingApps: false

    property int availableCellHeight: units.iconSizes.huge + reservedSpaceForLabel

    readonly property int reservedSpaceForLabel: metrics.height

    readonly property int cellWidth: applicationsFlow.width / Math.floor(applicationsFlow.width / ((availableCellHeight - reservedSpaceForLabel) + units.smallSpacing*4))
    readonly property int cellHeight: availableCellHeight - topPadding

    property ContainmentLayoutManager.AppletsLayout appletsLayout
    property FavoriteStrip favoriteStrip

    signal externalDragStarted
    signal dragPositionChanged(point pos)

    function forceLayout() {
        applicationsFlow.forceLayout();
    }

    function showSpacerBefore(item) {
        spacer.parent = applicationsFlow
        plasmoid.nativeInterface.orderItems(spacer, item);
    }

    function hideSpacer() {
        spacer.parent = flowParent;
    }

    implicitHeight: applicationsFlow.implicitHeight + frame.margins.top + frame.margins.bottom

    leftPadding: frame.margins.left
    topPadding: frame.margins.top
    rightPadding: frame.margins.right
    bottomPadding: frame.margins.bottom

    background: PlasmaCore.FrameSvgItem {
        id: frame
        imagePath: "widgets/background"
        anchors.fill: parent
    }

    contentItem: Item {
        id: flowParent
        //NOTE: TextMetrics can't handle multi line
        Controls.Label {
            id: metrics
            text: "M\nM"
            visible: false
        }

        Item {
            id: spacer
            width: units.gridUnit * 4
            height: width
            visible:parent == applicationsFlow
        }
        Flow {
            id: applicationsFlow
            anchors.fill: parent

            spacing: 0

            property var dragData
            property int startContentYDrag
            property bool viewHasBeenDragged


            NumberAnimation {
                id: scrollAnim
                target: applicationsFlow
                properties: "contentY"
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
            move: Transition {
                NumberAnimation {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                    properties: "x,y"
                }
            }

            Repeater {
                model: plasmoid.nativeInterface.applicationListModel
                delegate: Delegate {
                    width: root.cellWidth
                    height: root.cellHeight
                    container: {
                        if (model.ApplicationOnDesktopRole) {
                            return null;
                        }
                        if (index < favoriteStrip.count) {
                            return favoriteStrip;
                        }
                        return root;
                    }
                    parent: {
                        if (model.ApplicationOnDesktopRole) {
                            return appletsLayout;
                        }
                        if (index < favoriteStrip.count) {
                            if (editMode) {
                                return favoriteStrip.contentItem;
                            } else {
                                return favoriteStrip.flow;
                            }
                        }
                        if (editMode) {
                            return flowParent;
                        } else {
                            return applicationsFlow;
                        }
                    }
                }
            }
        }
    }
}
