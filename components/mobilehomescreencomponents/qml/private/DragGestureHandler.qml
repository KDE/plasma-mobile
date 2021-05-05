/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.14

import org.kde.plasma.core 2.0 as PlasmaCore

import ".." as Launcher

DragHandler {
    id: root
    yAxis.enabled: enabled
    xAxis.enabled: enabled
    property Flickable mainFlickable
    property Launcher.AppDrawer appDrawer
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
    property int __scrollDirection: DragGestureHandler.None
    onTranslationChanged: {
        if (active) {
            if (root.appDrawer) {
                if (__scrollDirection === DragGestureHandler.None) {
                    if (root.appDrawer.offset > PlasmaCore.Units.gridUnit) {

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
                    root.appDrawer.offset = -translation.y;
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
    }
    onActiveChanged: {
        if (active) {
            __initialMainFlickableX = mainFlickable.contentX;
        } else {
            if (root.appDrawer) {
                root.appDrawer.snapDrawerStatus();
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

