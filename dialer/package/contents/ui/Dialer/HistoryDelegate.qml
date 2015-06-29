/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: delegateParent
    width: view.width
    height: childrenRect.height

    Behavior on height {
        SpringAnimation { spring: 5; damping: 0.3 }
    }
    SequentialAnimation {
        id: removeAnim
        XAnimator {
            target: delegate
            from: delegate.x
            to: delegate.x > 0 ? width : -width
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: delegateParent
            properties: "height"
            to: 0
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
        ScriptAction {
            script: removeCallFromHistory(model.originalIndex);
        }
    }

    XAnimator {
        id: resetAnim
        target: delegate
        from: delegate.x
        to: 0
        duration: units.longDuration
        easing.type: Easing.InOutQuad
    }

    PlasmaComponents.ListItem {
        id: delegate

        MouseArea {
            width: parent.width
            height: childrenRect.height
            onClicked: call(model.number);
            drag.axis: Drag.XAxis
            drag.target: delegate
            onReleased: {
                if (drag.active) {
                    if (delegate.x > delegate.width / 3 || delegate.x < width / -3) {
                        removeAnim.running = true;
                    } else {
                        resetAnim.running = true;
                    }
                }
            }

            RowLayout {
                width: parent.width
                //FIXME: ad hoc icons
                PlasmaCore.IconItem {
                    width: units.iconSizes.medium
                    height: width
                    source: {
                        switch (model.callType) {
                        case 0:
                            return "list-remove";
                        case 1:
                            return "go-down";
                        case 2:
                            return "go-up";
                        }
                    }
                }
                ColumnLayout {
                    PlasmaComponents.Label {
                        text: "Name (todo)"
                    }
                    PlasmaComponents.Label {
                        text: model.number
                        Layout.fillWidth: true
                    }
                }
                ColumnLayout {
                    PlasmaComponents.Label {
                        Layout.alignment: Qt.AlignRight
                        text: Qt.formatTime(model.time, Qt.locale().timeFormat(Locale.ShortFormat));
                    }
                    PlasmaComponents.Label {
                        Layout.alignment: Qt.AlignRight
                        text: i18n("Duration: %1", secondsToTimeString(model.duration));
                        visible: model.duration > 0
                    }
                }
            }
        }
    }
}
