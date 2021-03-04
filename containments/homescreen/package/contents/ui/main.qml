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

import "launcher" as Launcher

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.phone.homescreen 1.0

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root
    width: 640
    height: 480

    property Item toolBox

//BEGIN functions
    //Autoscroll related functions
    function scrollLeft() {
        if (mainFlickable.atXBeginning) {
            return;
        }
        autoScrollTimer.scrollRight = false;
        autoScrollTimer.running = true;
        scrollLeftIndicator.opacity = 1;
        scrollRightIndicator.opacity = 0;
    }

    function scrollRight() {
        if (mainFlickable.atXEnd) {
            return;
        }
        autoScrollTimer.scrollRight = true;
        autoScrollTimer.running = true;
        scrollLeftIndicator.opacity = 0;
        scrollRightIndicator.opacity = 1;
    }

    function stopScroll() {
        autoScrollTimer.running = false;
        scrollLeftIndicator.opacity = 0;
        scrollRightIndicator.opacity = 0;
    }

    function recalculateMaxFavoriteCount() {
        if (!componentComplete) {
            return;
        }

        plasmoid.nativeInterface.applicationListModel.maxFavoriteCount = Math.max(4, Math.floor(Math.min(width, height) / appletsLayout.cellWidth));
    }

//END functions


    FastBlur {
        anchors.fill: parent
        source: wallpaper
        radius: 32
    }
    property bool componentComplete: false
    onWidthChanged: recalculateMaxFavoriteCount()
    onHeightChanged:recalculateMaxFavoriteCount()
    Component.onCompleted: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreen = root
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window
        }
        componentComplete = true;
        recalculateMaxFavoriteCount()
    }

    Plasmoid.onScreenChanged: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreen = root
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window
        }
    }
    Window.onWindowChanged: {
        if (plasmoid.screen == 0) {
            MobileShell.HomeScreenControls.homeScreenWindow = root.Window.window
        }
    }

    Connections {
        property real lastRequestedPosition: 0
        target: MobileShell.HomeScreenControls
        function onResetHomeScreenPosition() {
            scrollAnim.to = 0;
            scrollAnim.restart();
            appDrawer.close();
        }
        function onSnapHomeScreenPosition() {
            if (lastRequestedPosition > 0) {
                appDrawer.open();
            } else {
                appDrawer.close();
            }
        }
        function onRequestHomeScreenPosition(y) {
            appDrawer.offset += y;
            lastRequestedPosition = y;
        }
    }

    Timer {
        id: autoScrollTimer
        property bool scrollRight: true
        repeat: true
        interval: 1500
        onTriggered: {
            scrollAnim.to = scrollRight ?
            //Scroll Right
                Math.min(mainFlickable.contentItem.width - mainFlickable.width, mainFlickable.contentX + mainFlickable.width) :
            //Scroll Left
                Math.max(0, mainFlickable.contentX - mainFlickable.width);

            scrollAnim.running = true;
        }
    }

    Connections {
        target: plasmoid
        onEditModeChanged: {
            appletsLayout.editMode = plasmoid.editMode
        }
    }

    Launcher.LauncherDragManager {
        id: launcherDragManager
        anchors.fill: parent
        z: 2
        appletsLayout: appletsLayout
        favoriteStrip: favoriteStrip
    }

    //TODO: this flickable does nothing for now, will be used for horizontal paging
    Flickable {
        id: mainFlickable

        anchors {
            fill: parent
            topMargin: plasmoid.availableScreenRect.y
            bottomMargin: favoriteStrip.height + plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
        }

        opacity: 1 - appDrawer.openFactor
        transform: Translate {
            y: -mainFlickable.height/10 * appDrawer.openFactor
        }
        scale: (3 - appDrawer.openFactor) /3

        //bottomMargin: favoriteStrip.height
        contentWidth: appletsLayout.width
        contentHeight: height
        interactive: !plasmoid.editMode && !launcherDragManager.active

        signal cancelEditModeForItemsRequested
        onDragStarted: cancelEditModeForItemsRequested()
        onDragEnded: cancelEditModeForItemsRequested()
        onFlickStarted: cancelEditModeForItemsRequested()
        onFlickEnded: cancelEditModeForItemsRequested()

        onContentYChanged: MobileShell.HomeScreenControls.homeScreenPosition = contentY

        DragHandler {
            target: mainFlickable
            yAxis.enabled: !appletsLayout.editMode
            enabled: root.focus && appDrawer.status !== Launcher.AppDrawer.Status.Open
            onTranslationChanged: {
                if (active) {
                    appDrawer.offset = -translation.y
                }
            }
            onActiveChanged: {
                if (!active) {
                    appDrawer.snapDrawerStatus();
                }
            }
        }

        NumberAnimation {
            id: scrollAnim
            target: mainFlickable
            properties: "contentX"
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }


        // TODO: span on multiple pages
        DragDrop.DropArea {
            id: dropArea
            width: mainFlickable.width
            height: mainFlickable.height + favoriteStrip.height

            onDragEnter: {
                event.accept(event.proposedAction);
                launcherDragManager.active = true;
            }
            onDragMove: {
                let posInFavorites = favoriteStrip.mapFromItem(this, event.x, event.y);
                if (posInFavorites.y > 0) {
                    if (plasmoid.nativeInterface.applicationListModel.favoriteCount >= plasmoid.nativeInterface.applicationListModel.maxFavoriteCount ) {
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
                        if (plasmoid.nativeInterface.applicationListModel.favoriteCount >= plasmoid.nativeInterface.applicationListModel.maxFavoriteCount ) {
                            return;
                        }

                        let pos = Math.min(plasmoid.nativeInterface.applicationListModel.count, Math.floor(posInFavorites.x/favoriteStrip.cellWidth))
                        plasmoid.nativeInterface.applicationListModel.addFavorite(storageId, pos, ApplicationListModel.Favorites)
                        let item = launcherRepeater.itemAt(pos);

                        if (item) {
                            item.x = posInFavorites.x;
                            item.y = 0//posInFavorites.y;

                            //launcherDragManager.showSpacer(item, item.width/2, item.height/2);
                            launcherDragManager.dropItem(item, item.width/2, item.height/2);
                        }

                        return;
                    }


                    let pos = plasmoid.nativeInterface.applicationListModel.count;
                    plasmoid.nativeInterface.applicationListModel.addFavorite(storageId, pos, ApplicationListModel.Desktop)
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

            PlasmaCore.Svg {
                id: arrowsSvg
                imagePath: "widgets/arrows"
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
            }

            ContainmentLayoutManager.AppletsLayout {
                id: appletsLayout

                anchors {
                    fill: parent
                    bottomMargin: favoriteStrip.height
                }

                signal appletsLayoutInteracted

                TapHandler {
                    target: mainFlickable
                    enabled: appDrawer.status !== Launcher.AppDrawer.Status.Open
                    onTapped: {
                        //Hides icons close button
                        appletsLayout.appletsLayoutInteracted();
                        appletsLayout.editMode = false;
                    }
                    onLongPressed: appletsLayout.editMode = true;
                    onPressedChanged: root.focus = true;
                }

                cellWidth: favoriteStrip.cellWidth
                cellHeight: Math.floor(height / Math.floor(height / favoriteStrip.cellHeight))

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

                acceptsAppletCallback: function(applet, x, y) {
                    print("Applet: "+applet+" "+x+" "+y)
                    return true;
                }

                appletContainerComponent: ContainmentLayoutManager.BasicAppletContainer {
                    id: appletContainer
                    configOverlayComponent: ConfigOverlay {}

                    onEditModeChanged: {
                        launcherDragManager.active = dragActive || editMode;
                    }
                    onDragActiveChanged: {
                        launcherDragManager.active = dragActive || editMode;
                    }
                }

                placeHolder: ContainmentLayoutManager.PlaceHolder {}
                //FIXME: move
                PlasmaComponents.Label {
                        id: metrics
                        text: "M\nM"
                        visible: false
                        font.pointSize: theme.defaultFont.pointSize * 0.9
                    }
                Launcher.LauncherRepeater {
                    id: launcherRepeater
                    cellWidth: appletsLayout.cellWidth
                    cellHeight: appletsLayout.cellHeight
                    appletsLayout: appletsLayout
                    favoriteStrip: favoriteStrip
                }
            }
        }
    }

    Launcher.AppDrawer {
        id: appDrawer
        anchors.fill: parent

        topPadding: plasmoid.availableScreenRect.y
        bottomPadding: favoriteStrip.height + plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
    }

    ScrollIndicator {
        id: scrollLeftIndicator
        anchors {
            left: parent.left
            leftMargin: units.smallSpacing
        }
        elementId: "left-arrow"
    }
    ScrollIndicator {
        id: scrollRightIndicator
        anchors {
            right: parent.right
            rightMargin: units.smallSpacing
        }
        elementId: "right-arrow"
    }

    Launcher.FavoriteStrip {
        id: favoriteStrip
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
        }
        appletsLayout: appletsLayout

        DragHandler {
            target: favoriteStrip
            yAxis.enabled: !appletsLayout.editMode
            enabled: root.focus && appDrawer.status !== Launcher.AppDrawer.Status.Open
            onTranslationChanged: {
                if (active) {
                    appDrawer.offset = -translation.y
                }
            }
            onActiveChanged: {
                if (!active) {
                    appDrawer.snapDrawerStatus();
                }
            }
        }
        TapHandler {
            target: favoriteStrip
            onTapped: {
                //Hides icons close button
                appletsLayout.appletsLayoutInteracted();
                appletsLayout.editMode = false;
            }
            onLongPressed: appletsLayout.editMode = true;
            onPressedChanged: root.focus = true;
        }
    }
}

