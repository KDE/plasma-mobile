// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

GridView {
    maximumFlickVelocity: 5000

    highlightFollowsCurrentItem: true
    highlight: highlightComponent

    /** These function are called when the user tries to move the highlight outside the allowed surface by using arrow keys.
      * Useful to override the default behaviour of GridView (Pac-Man effect).
      */
    property var topEdgeCallback: null
    property var bottomEdgeCallback: null
    property var leftEdgeCallback: null
    property var rightEdgeCallback: null

    Keys.onPressed: event => {
                        if (!currentItem) {
                            return;
                        }

                        switch(event.key){
                            case Qt.Key_Left: {
                                if (currentItem.x === 0
                                    && leftEdgeCallback) {
                                    leftEdgeCallback();
                                }
                                break;
                            }
                            case Qt.Key_Right: {
                                if (indexAt(currentItem.x + cellWidth, currentItem.y) === -1
                                    && rightEdgeCallback) {
                                    rightEdgeCallback();
                                }
                                break;
                            }
                            case Qt.Key_Up: {
                                if (currentItem.y === 0
                                    && topEdgeCallback) {
                                    topEdgeCallback();
                                }
                                break;
                            }
                            case Qt.Key_Down: {
                                if (indexAt(currentItem.x, currentItem.y + cellHeight) === -1
                                    && bottomEdgeCallback) {
                                    bottomEdgeCallback();
                                }
                                break;
                            }
                        }
                    }

    onActiveFocusChanged: {
        if (!activeFocus) {
            currentIndex = -1;
        }
    }

    onDraggingChanged: {
        if (dragging) {
            currentIndex = -1;
        }
    }

    Component {
        id: highlightComponent
        Rectangle {
            color: Kirigami.ColorUtils.tintWithAlpha(PlasmaCore.ColorScope.highlightColor, PlasmaCore.ColorScope.backgroundColor, 0.6)
            radius: PlasmaCore.Units.smallSpacing

            Behavior on x { SpringAnimation { spring: 3; damping: 0.2 } }
            Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }
        }
    }
}
