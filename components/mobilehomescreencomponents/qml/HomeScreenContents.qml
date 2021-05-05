/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

import "private" as Private

DragDrop.DropArea {
    id: dropArea
    width: mainFlickable.width * 100
    //width: Math.max(mainFlickable.width, mainFlickable.width * Math.ceil(appletsLayout.childrenRect.width/mainFlickable.width))
    height: mainFlickable.height

    property alias launcherDelegate: launcherRepeater.delegate
    property alias launcherModel: launcherRepeater.model
    property alias launcherRepeater: launcherRepeater
    property alias itemsBoundingRect: appletsLayout.childrenRect

    property alias appletsLayout: appletsLayout

    property FavoriteStrip favoriteStrip

    property LauncherDragManager launcherDragManager: LauncherDragManager {
        id: launcherDragManager
        parent: {
            let candidate = dropArea;
            while (candidate.parent) {
                candidate = candidate.parent;
            }
            return candidate;
        }
        anchors.fill: parent
        z: 999999
        appletsLayout: homeScreenContents.appletsLayout
        favoriteStrip: dropArea.favoriteStrip
    }

    Connections {
        target: plasmoid
        function onEditModeChanged() {
            appletsLayout.editMode = plasmoid.editMode
        }
    }

    onDragEnter: {
        event.accept(event.proposedAction);
        launcherDragManager.active = true;
    }
    onDragMove: {
        let posInFavorites = favoriteStrip.mapFromItem(this, event.x, event.y);
        if (posInFavorites.y > 0) {
            if (HomeScreenComponents.ApplicationListModel.favoriteCount >= HomeScreenComponents.ApplicationListModel.maxFavoriteCount ) {
                launcherDragManager.hideSpacer();
            } else {
                launcherDragManager.showSpacerAtPos(event.x, event.y, favoriteStrip);
            }
            appletsLayout.hidePlaceHolder();
        } else {
            appletsLayout.showPlaceHolderAt(
                Qt.rect(event.x - appletsLayout.defaultItemWidth / 2,
                event.y - appletsLayout.defaultItemHeight / 2,
                appletsLayout.defaultItemWidth,
                appletsLayout.defaultItemHeight)
            );
            launcherDragManager.hideSpacer();

            let scenePos = mapToItem(null, event.x, event.y);
            //SCROLL LEFT
            if (scenePos.x < units.gridUnit) {
                mainFlickable.scrollLeft();
            //SCROLL RIGHT
            } else if (scenePos.x > mainFlickable.width - units.gridUnit) {
                mainFlickable.scrollRight();
            //DON't SCROLL
            } else {
                mainFlickable.stopScroll();
            }
        }
    }

    onDragLeave: {
        appletsLayout.hidePlaceHolder();
        launcherDragManager.active = false;
    }

    preventStealing: true

    onDrop: {
        launcherDragManager.active = false;
        if (event.mimeData.formats[0] === "text/x-plasma-phone-homescreen-launcher") {
            let storageId = event.mimeData.getDataAsByteArray("text/x-plasma-phone-homescreen-launcher");

            let posInFavorites = favoriteStrip.flow.mapFromItem(this, event.x, event.y);
            if (posInFavorites.y > 0) {
                if (HomeScreenComponents.ApplicationListModel.favoriteCount >= HomeScreenComponents.ApplicationListModel.maxFavoriteCount ) {
                    return;
                }

                let pos = Math.min(HomeScreenComponents.FavoritesModel.count, Math.floor(posInFavorites.x/favoriteStrip.cellWidth))
                HomeScreenComponents.FavoritesModel.addFavorite(storageId, pos, HomeScreenComponents.ApplicationListModel.Favorites)
                let item = launcherRepeater.itemAt(pos);

                if (item) {
                    item.x = posInFavorites.x;
                    item.y = 0//posInFavorites.y;

                    //launcherDragManager.showSpacer(item, item.width/2, item.height/2);
                    launcherDragManager.dropItem(item, item.width/2, item.height/2);
                }

                return;
            }

            let pos = HomeScreenComponents.FavoritesModel.count;
            HomeScreenComponents.FavoritesModel.addFavorite(storageId, pos, HomeScreenComponents.ApplicationListModel.Desktop)
            let item = launcherRepeater.itemAt(pos);

            event.accept(event.proposedAction);
            if (item) {
                item.x = appletsLayout.placeHolder.x;
                item.y = appletsLayout.placeHolder.y;
                appletsLayout.hidePlaceHolder();
                launcherDragManager.dropItem(item, appletsLayout.placeHolder.x + appletsLayout.placeHolder.width/2, appletsLayout.placeHolder.y + appletsLayout.placeHolder.height/2);
            }
            appletsLayout.hidePlaceHolder();
        } else {
            plasmoid.processMimeData(event.mimeData,
                        event.x - appletsLayout.placeHolder.width / 2, event.y - appletsLayout.placeHolder.height / 2);
            event.accept(event.proposedAction);
            appletsLayout.hidePlaceHolder();
        }
    }

    ContainmentLayoutManager.AppletsLayout {
        id: appletsLayout

        anchors {
            fill: parent
            bottomMargin: dropArea.favoriteStrip ? dropArea.favoriteStrip.height : 0
        }

        signal appletsLayoutInteracted

        TapHandler {
            target: mainFlickable
            enabled: appDrawer.status !== AppDrawer.Status.Open
            onTapped: {
                //Hides icons close button
                appletsLayout.appletsLayoutInteracted();
                appletsLayout.editMode = false;
                appletsLayout.forceActiveFocus();
            }
            onLongPressed: appletsLayout.editMode = true;
            onPressedChanged: appletsLayout.focus = true;
        }

        cellWidth: favoriteStrip.cellWidth
        cellHeight: Math.floor(height / Math.floor(height / favoriteStrip.cellHeight))

        configKey: width > height ? "ItemGeometriesHorizontal" : "ItemGeometriesVertical"
        containment: plasmoid
        editModeCondition: plasmoid.immutable
                ? ContainmentLayoutManager.AppletsLayout.Manual
                : ContainmentLayoutManager.AppletsLayout.AfterPressAndHold

        // Sets the containment in edit mode when we go in edit mode as well
        onEditModeChanged: plasmoid.editMode = editMode;

        minimumItemWidth: units.gridUnit * 3
        minimumItemHeight: minimumItemWidth

        defaultItemWidth: units.gridUnit * 6
        defaultItemHeight: defaultItemWidth

        acceptsAppletCallback: function(applet, x, y) {
            print("Applet: "+applet+" "+x+" "+y)
            return true;
        }
        appletContainerComponent: MobileAppletContainer {
            launcherDragManager: dropArea.launcherDragManager
        }

        placeHolder: ContainmentLayoutManager.PlaceHolder {}
        //FIXME: move
        PlasmaComponents.Label {
                id: metrics
                text: "M\nM"
                visible: false
                font.pointSize: theme.defaultFont.pointSize * 0.9
            }
        LauncherRepeater {
            id: launcherRepeater
            cellWidth: appletsLayout.cellWidth
            cellHeight: appletsLayout.cellHeight
            appletsLayout: appletsLayout
            favoriteStrip: dropArea.favoriteStrip
            onScrollLeftRequested: mainFlickable.scrollLeft()
            onScrollRightRequested: mainFlickable.scrollRight()
            onStopScrollRequested: mainFlickable.stopScroll()
        }
    }
}


