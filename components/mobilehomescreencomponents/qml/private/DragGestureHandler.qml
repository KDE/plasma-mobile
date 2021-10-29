/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.14

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import ".." as Launcher

DragHandler {
    id: root
    yAxis.enabled: enabled
    xAxis.enabled: enabled
    property Flickable mainFlickable
    property Launcher.AbstractAppDrawer appDrawer
    signal snapPage
    signal snapNextPage
    signal snapPrevPage

    enum ScrollDirection {
        None,
        Left,
        Right,
        Vertical
    }

    property real __initialMainFlickableX
    property real __oldTranslationY: 0
    property int __scrollDirection: DragGestureHandler.None
    onTranslationChanged: {
        if (active) {
            if (root.appDrawer) {
                if (__scrollDirection === DragGestureHandler.None) {
                    if (root.appDrawer.flickable.contentY > PlasmaCore.Units.gridUnit * 2) {

                        __scrollDirection = DragGestureHandler.Vertical;
                        snapPage();
                    } else if (mainFlickable.contentX - __initialMainFlickableX > PlasmaCore.Units.gridUnit) {

                        __scrollDirection = DragGestureHandler.Right;
                        root.appDrawer.close();
                    } else if (__initialMainFlickableX - mainFlickable.contentX > PlasmaCore.Units.gridUnit) {

                        __scrollDirection = DragGestureHandler.Left;
                        root.appDrawer.close();
                    }
                }

                if (__scrollDirection !== DragGestureHandler.Left && __scrollDirection !== DragGestureHandler.Right) {
                    // if swipe up, scroll app drawer
                    root.appDrawer.flickable.contentY = Math.min(root.appDrawer.drawerTopMargin, Math.max(0, -translation.y));
                    
                    if (translation.y < 0 && MobileShell.TopPanelControls.inSwipe) {
                        MobileShell.TopPanelControls.endSwipe();
                    }
                    
                    // if swipe down, scroll top panel
                    if (translation.y > 0) {
                        if (!MobileShell.TopPanelControls.inSwipe) {
                            MobileShell.TopPanelControls.startSwipe();
                        }
                        MobileShell.TopPanelControls.requestRelativeScroll(translation.y - __oldTranslationY);
                    }
                }
            }
            if (__scrollDirection !== DragGestureHandler.Vertical) {
                let newContentX = Math.min((mainFlickable.width * mainFlickable.totalPages) - mainFlickable.width, Math.max(0, __initialMainFlickableX - translation.x));

                if (__scrollDirection !== DragGestureHandler.None) {
                    if (mainFlickable.contentX < newContentX) {
                        __scrollDirection = DragGestureHandler.Right;
                    } else {
                        __scrollDirection = DragGestureHandler.Left;
                    }
                }

                mainFlickable.contentX = newContentX;
            }
        }
        
        __oldTranslationY = translation.y;
    }
    
    onActiveChanged: {
        if (active) {
            __initialMainFlickableX = mainFlickable.contentX;
        } else {
            if (root.appDrawer) {
                root.appDrawer.snapDrawerStatus();
            }
            if (MobileShell.TopPanelControls.inSwipe) {
                MobileShell.TopPanelControls.endSwipe();
            }
            if (__scrollDirection === DragGestureHandler.Left && (__initialMainFlickableX - mainFlickable.contentX > PlasmaCore.Units.gridUnit * 5)) {
                snapPrevPage();
            } else if (__scrollDirection === DragGestureHandler.Right && (mainFlickable.contentX - __initialMainFlickableX > PlasmaCore.Units.gridUnit * 5)) {
                snapNextPage();
            } else {
                snapPage();
            }
            __scrollDirection = DragGestureHandler.None;
        }
    }
}

