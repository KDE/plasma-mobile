/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
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

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Flickable {
    id: mainFlickable
    
    required property var homeScreenState
    
    property Item footer

    property bool showAddPageIndicator: false

    contentX: homeScreenState.xPosition
    
    contentHeight: height
    interactive: false

    signal cancelEditModeForItemsRequested
    onDragStarted: cancelEditModeForItemsRequested()
    onDragEnded: cancelEditModeForItemsRequested()
    onFlickStarted: cancelEditModeForItemsRequested()
    onFlickEnded: cancelEditModeForItemsRequested()

    onFooterChanged: {
        if (footer) {
            footer.parent = mainFlickable;
            footer.anchors.left = mainFlickable.left;
            footer.anchors.bottom = mainFlickable.bottom;
            footer.anchors.right = mainFlickable.right;
        }
    }

    // autoscroll between pages (when holding a delegate to go to a new page)
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

    Timer {
        id: autoScrollTimer
        property bool scrollRight: true
        repeat: true
        interval: 1500
        onTriggered: {
            homeScreenState.animateGoToPageIndex(Math.max(0, homeScreenState.currentPageIndex + (scrollRight ? 1 : -1)), PlasmaCore.Units.longDuration * 2);
        }
    }
    
    PlasmaComponents.PageIndicator {
        id: pageIndicator
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: mainFlickable.footer ? mainFlickable.footer.height : 0
        }
        
        PlasmaCore.ColorScope.inherit: false
        PlasmaCore.ColorScope.colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        
        parent: mainFlickable
        visible: count > 1
        
        count: homeScreenState.pagesCount
        currentIndex: homeScreenState.currentPageIndex
        
        delegate: Rectangle {
            property bool isAddPageIndicator: index === pageIndicator.count-1 && mainFlickable.showAddPageIndicator
            implicitWidth: PlasmaCore.Units.gridUnit/2
            implicitHeight: implicitWidth
            
            radius: width
            color: isAddPageIndicator ? "transparent" : PlasmaCore.ColorScope.textColor

            PlasmaComponents.Label {
                anchors.centerIn: parent
                visible: parent.isAddPageIndicator
                text: "⊕"
            }

            opacity: index === pageIndicator.currentIndex ? 0.9 : pressed ? 0.7 : 0.5
            Behavior on opacity {
                OpacityAnimator {
                    duration: PlasmaCore.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    Item {
        z: 9999999
        anchors.fill: parent
        parent: {
            let candidate = mainFlickable;
            while (candidate.parent) {
                candidate = candidate.parent;
            }
            return candidate;
        }

        Private.ScrollIndicator {
            id: scrollLeftIndicator
            anchors {
                left: parent.left
                leftMargin: PlasmaCore.Units.smallSpacing
            }
            elementId: "left-arrow"
        }
        Private.ScrollIndicator {
            id: scrollRightIndicator
            anchors {
                right: parent.right
                rightMargin: PlasmaCore.Units.smallSpacing
            }
            elementId: "right-arrow"
        }
    }
}


