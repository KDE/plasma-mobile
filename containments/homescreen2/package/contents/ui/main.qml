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

import "launcher" as Launcher

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

Item {
    id: root
    width: 640
    height: 480

    property Item toolBox

Text {
    text:"Edit Mode"
    color: "white"
    visible: plasmoid.editMode
}
    Connections {
        target: plasmoid
        onEditModeChanged: {
            appletsLayout.editMode = plasmoid.editMode
        }
    }

    Flickable {
        id: mainFlickable
        anchors {
            fill: parent
           // bottomMargin: favoriteStrip.height
        }
        
        bottomMargin: favoriteStrip.height
        contentWidth: width
        contentHeight: flickableContents.height
        interactive: !plasmoid.editMode && !launcher.dragging

        ColumnLayout {
            id: flickableContents
            width: parent.width
            DragDrop.DropArea {
                Layout.fillWidth: true
                Layout.preferredHeight: mainFlickable.height //TODO: multiple widgets pages

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

                PlasmaCore.Svg {
                    id: arrowsSvg
                    imagePath: "widgets/arrows"
                    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                }
                PlasmaCore.SvgItem {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: favoriteStrip.height
                    }
                    z: 2
                    svg: arrowsSvg
                    elementId: "up-arrow"
                    width: units.iconSizes.large
                    height: width
                }

                ContainmentLayoutManager.AppletsLayout {
                    id: appletsLayout

                    anchors.fill: parent

                    configKey: width > height ? "ItemGeometriesHorizontal" : "ItemGeometriesVertical"
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
                        onEditModeChanged: {
                            if (editMode) {
                                plasmoid.editMode = true;
                            }
                        }
                    }

                    placeHolder: ContainmentLayoutManager.PlaceHolder {}
                }
            }
            Launcher.LauncherGrid {
                id: launcher
                Layout.fillWidth: true
                
                favoriteStrip: favoriteStrip
                appletsLayout: appletsLayout
            }
        }
    }
    Launcher.FavoriteStrip {
        id: favoriteStrip
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(root.width, implicitWidth)
        launcherGrid: launcher
        y: Math.max(0, root.height - height - mainFlickable.contentY)
    }
}

