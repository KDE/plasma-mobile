/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragDrop

import "private" as Private

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.phone.homescreen 1.0

import org.kde.plasma.private.mobileshell 1.0 as MobileShell


Flickable {
    id: mainFlickable

    property AppDrawer appDrawer

    readonly property int totalPages: Math.ceil(contentWidth / width)
    property int currentIndex: 0

    property ContainmentLayoutManager.AppletsLayout appletsLayout: null

    opacity: 1 - appDrawer.openFactor
    transform: Translate {
        y: -mainFlickable.height/10 * appDrawer.openFactor
    }
    scale: (3 - appDrawer.openFactor) /3

    //bottomMargin: favoriteStrip.height
    contentHeight: height
    //interactive: !plasmoid.editMode && !launcherDragManager.active
    interactive: false

    signal cancelEditModeForItemsRequested
    onDragStarted: cancelEditModeForItemsRequested()
    onDragEnded: cancelEditModeForItemsRequested()
    onFlickStarted: cancelEditModeForItemsRequested()
    onFlickEnded: cancelEditModeForItemsRequested()

    //onCurrentIndexChanged: contentX = width * currentIndex;
    onContentXChanged: mainFlickable.currentIndex = Math.floor(contentX / width)


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

    function snapPage() {
        scrollAnim.running = false;
        scrollAnim.to = mainFlickable.width * Math.round(mainFlickable.contentX / mainFlickable.width)
        scrollAnim.running = true;
    }

    function snapNextPage() {
        scrollAnim.running = false;
        scrollAnim.to = mainFlickable.width * Math.ceil(mainFlickable.contentX / mainFlickable.width)
        scrollAnim.running = true;
    }

    function snapPrevPage() {
        scrollAnim.running = false;
        scrollAnim.to = mainFlickable.width * Math.floor(mainFlickable.contentX / mainFlickable.width)
        scrollAnim.running = true;
    }
    function scrollToPage(index) {
        scrollAnim.running = false;
        scrollAnim.to = mainFlickable.width * Math.max(0, Math.min(index, mainFlickable.contentWidth - mainFlickable.width))
        scrollAnim.running = true;
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

    Private.DragGestureHandler {
        id: gestureHandler
        target: appletsLayout
        appDrawer: mainFlickable.appDrawer
        mainFlickable: mainFlickable
        enabled: root.focus && appDrawer.status !== AppDrawer.Status.Open && !appletsLayout.editMode && !plasmoid.editMode && !launcherDragManager.active
        onSnapPage: mainFlickable.snapPage();
        onSnapNextPage: mainFlickable.snapNextPage();
        onSnapPrevPage: mainFlickable.snapPrevPage();
    }

    NumberAnimation {
        id: scrollAnim
        target: mainFlickable
        properties: "contentX"
        duration: units.longDuration
        easing.type: Easing.InOutQuad
    }


    PlasmaComponents.PageIndicator {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: PlasmaCore.Units.gridUnit * 2
        }
        PlasmaCore.ColorScope.inherit: false
        PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        parent: mainFlickable
        count: mainFlickable.totalPages
        visible: count > 1
        currentIndex: Math.round(mainFlickable.contentX / mainFlickable.width)
    }

    Private.ScrollIndicator {
        id: scrollLeftIndicator
        parent: mainFlickable
        anchors {
            left: parent.left
            leftMargin: units.smallSpacing
        }
        elementId: "left-arrow"
    }
    Private.ScrollIndicator {
        id: scrollRightIndicator
        parent: mainFlickable
        anchors {
            right: parent.right
            rightMargin: units.smallSpacing
        }
        elementId: "right-arrow"
    }
}


