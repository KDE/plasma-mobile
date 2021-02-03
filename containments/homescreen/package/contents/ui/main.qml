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
    function scrollUp() {
        autoScrollTimer.scrollDown = false;
        autoScrollTimer.running = true;
        scrollUpIndicator.opacity = 1;
        scrollDownIndicator.opacity = 0;
    }

    function scrollDown() {
        autoScrollTimer.scrollDown = true;
        autoScrollTimer.running = true;
        scrollUpIndicator.opacity = 0;
        scrollDownIndicator.opacity = 1;
    }

    function stopScroll() {
        autoScrollTimer.running = false;
        scrollUpIndicator.opacity = 0;
        scrollDownIndicator.opacity = 0;
    }

    function recalculateMaxFavoriteCount() {
        if (!componentComplete) {
            return;
        }

        plasmoid.nativeInterface.applicationListModel.maxFavoriteCount = Math.max(4, Math.floor(Math.min(width, height) / launcher.cellWidth));
    }
//END functions

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
        target: MobileShell.HomeScreenControls
        function onResetHomeScreenPosition() {
            scrollAnim.to = 0;
            scrollAnim.restart();
        }
        function onSnapHomeScreenPosition() {
            mainFlickable.flick(0, 1);
        }
        function onRequestHomeScreenPosition(y) {
            mainFlickable.contentY = y;
        }
    }

    Timer {
        id: autoScrollTimer
        property bool scrollDown: true
        repeat: true
        interval: 1500
        onTriggered: {
            scrollAnim.to = scrollDown ?
            //Scroll down
                Math.min(mainFlickable.contentItem.height - root.height, mainFlickable.contentY + root.height/2) :
            //Scroll up
                Math.max(0, mainFlickable.contentY - root.height/2);

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
        launcherGrid: launcher
        favoriteStrip: favoriteStrip
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: -1
            rightMargin: -1
        }
        border.color: Qt.rgba(1, 1, 1, 0.5)
        radius: units.gridUnit
        color: "black"
        opacity: 0.4 * Math.min(1, mainFlickable.contentY / (units.gridUnit * 10))
        height: root.height + radius * 2
        y: Math.max(-radius, -mainFlickable.contentY + arrowUpIcon.y)
    }

    Flickable {
        id: mainFlickable
        width: parent.width
        clip: true
        anchors {
            fill: parent
            //topMargin: plasmoid.availableScreenRect.y
            bottomMargin: favoriteStrip.height + plasmoid.screenGeometry.height - plasmoid.availableScreenRect.height - plasmoid.availableScreenRect.y
        }

        //bottomMargin: favoriteStrip.height
        contentWidth: width
        contentHeight: flickableContents.height
        interactive: !plasmoid.editMode && !launcherDragManager.active

        signal cancelEditModeForItemsRequested
        onDragStarted: cancelEditModeForItemsRequested()
        onDragEnded: cancelEditModeForItemsRequested()
        onFlickStarted: cancelEditModeForItemsRequested()
        onFlickEnded: cancelEditModeForItemsRequested()

        onContentYChanged: MobileShell.HomeScreenControls.homeScreenPosition = contentY

        PlasmaComponents.ScrollBar.vertical: PlasmaComponents.ScrollBar {
            id: scrollabr
            opacity: mainFlickable.moving
            interactive: false
            enabled: false
            Behavior on opacity {
                OpacityAnimator {
                    duration: units.longDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }
            implicitWidth: Math.round(units.gridUnit/3)
            contentItem: Rectangle {
                radius: width/2
                color: Qt.rgba(1, 1, 1, 0.3)
                border.color: Qt.rgba(0, 0, 0, 0.4)
            }
        }
        NumberAnimation {
            id: scrollAnim
            target: mainFlickable
            properties: "contentY"
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }

        Column {
            id: flickableContents
            width: mainFlickable.width
            spacing: 0

            Item {
                width: 1
                height: plasmoid.availableScreenRect.y
            }
            DragDrop.DropArea {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: mainFlickable.height - plasmoid.availableScreenRect.y //TODO: multiple widgets pages

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
                MouseArea {
                    id: arrowUpIcon
                    z: 9
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: -units.smallSpacing
                    }
                    property real factor: Math.max(0, Math.min(1, mainFlickable.contentY / (mainFlickable.height/2)))

                    height: units.iconSizes.medium
                    onClicked: {
                        if (mainFlickable.contentY >= mainFlickable.height/2) {
                            scrollAnim.to = 0;
                        } else {
                            scrollAnim.to = mainFlickable.height/2
                        }
                        scrollAnim.restart();
                    }
                    Item {
                        anchors.centerIn: parent

                        width: units.iconSizes.medium
                        height: width

                        Rectangle {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.horizontalCenter
                                left: parent.left
                                verticalCenterOffset: -arrowUpIcon.height/4 + (arrowUpIcon.height/4) * arrowUpIcon.factor
                            }
                            color: theme.backgroundColor
                            transformOrigin: Item.Right
                            rotation: -45 + 90 * arrowUpIcon.factor
                            antialiasing: true
                            height: 1
                        }
                        Rectangle {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.horizontalCenter
                                right: parent.right
                                verticalCenterOffset: -arrowUpIcon.height/4 + (arrowUpIcon.height/4) * arrowUpIcon.factor
                            }
                            color: theme.backgroundColor
                            transformOrigin: Item.Left
                            rotation: 45 - 90 * arrowUpIcon.factor
                            antialiasing: true
                            height: 1
                        }
                    }
                }

                ContainmentLayoutManager.AppletsLayout {
                    id: appletsLayout

                    anchors.fill: parent

                    cellWidth: Math.floor(width / launcher.columns)
                    cellHeight: launcher.cellHeight

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

                    //cellWidth: units.iconSizes.small
                    //cellHeight: cellWidth

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
                }
            }

            Launcher.LauncherGrid {
                id: launcher
                anchors {
                    left: parent.left
                    right: parent.right
                }
                onLaunched: scrollResetTimer.restart();
                favoriteStrip: favoriteStrip
                appletsLayout: appletsLayout
            }
            Timer {
                id: scrollResetTimer
                interval: 1000
                onTriggered: {
                    scrollAnim.to = 0;
                    scrollAnim.restart();
                }
            }
        }
    }

    ScrollIndicator {
        id: scrollUpIndicator
        anchors {
            top: parent.top
            topMargin: units.gridUnit * 2
        }
        elementId: "up-arrow"
    }
    ScrollIndicator {
        id: scrollDownIndicator
        anchors {
            bottom: favoriteStrip.top
            bottomMargin: units.gridUnit
        }
        elementId: "down-arrow"
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: favoriteStrip.top
            leftMargin: units.gridUnit
            rightMargin: units.gridUnit
        }
        height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.15; color: Qt.rgba(1, 1, 1, 0.5) }
            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 1) }
            GradientStop { position: 0.85; color: Qt.rgba(1, 1, 1, 0.5) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }
        opacity: mainFlickable.contentY > 0 ? 0.6 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }
    }

    MouseArea {
        anchors.fill:favoriteStrip
        property real oldMouseY
        onPressed: oldMouseY = mouse.y
        onPositionChanged: {
            mainFlickable.contentY -= mouse.y - oldMouseY;
            oldMouseY = mouse.y;
        }
        onReleased: {
            mainFlickable.flick(0, 1);
        }
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
        launcherGrid: launcher
        //y: Math.max(krunner.inputHeight, root.height - height - mainFlickable.contentY)
    }
}

