/*
 * Copyright (C) 2015 Vishesh Handa <vhanda@kde.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) version 3, or any
 * later version accepted by the membership of KDE e.V. (or its
 * successor approved by the membership of KDE e.V.), which shall
 * act as a proxy defined in Section 6 of version 3 of the license.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.milou 0.1 as Milou

Rectangle {
    id: krunner
    anchors.fill: parent
    height: childrenRect.height
    color: listView.visible ? Qt.rgba(0, 0, 0, 0.8) : "transparent"
    property alias showingResults: listView.visible
    property int inputHeight: queryField.height + background.fixedMargins.top/2 + background.fixedMargins.bottom

    MouseArea {
        enabled: listView.visible
        anchors.fill: parent
        preventStealing: true
        onClicked: queryField.text = "";
    }
    PlasmaCore.FrameSvgItem {
        id: background
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        clip: true
        imagePath: "widgets/background"
        enabledBorders: PlasmaCore.FrameSvg.BottomBorder
        height: childrenRect.height + fixedMargins.top/2 + fixedMargins.bottom
        Behavior on height {
            NumberAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        transform: Translate {
            y: root.locked || editOverlay.visible ? -background.height : 0
            Behavior on y {
                NumberAnimation {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        ColumnLayout {
            height: Qt.inputMethod.keyboardRectangle.height > 0 ? (Math.min(implicitHeight, Qt.inputMethod.keyboardRectangle.y - plasmoid.availableScreenRect.y)) : implicitHeight
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: background.fixedMargins.top / 2
                leftMargin: background.fixedMargins.left / 2
                rightMargin: background.fixedMargins.right / 2
            }
            PlasmaComponents.TextField {
                id: queryField
                clearButtonShown: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                Keys.onEscapePressed: runnerWindow.visible = false
                placeholderText: "Search ..."
            }

            PlasmaExtras.ScrollArea {
                visible: listView.count > 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: listView.contentHeight
                Layout.alignment: Qt.AlignTop

                Milou.ResultsListView {
                    id: listView
                    queryString: queryField.text
                    highlight: null

                    onActivated: queryField.text = ""
                    onUpdateQueryString: {
                        queryField.text = text
                        queryField.cursorPosition = cursorPosition
                    }
                }
            }

            Keys.onReturnPressed: {
                if (queryField.texr.length == 0)
                    runnerWindow.visible = false;
            }
            Keys.onEnterPressed: {
                if (queryField.texr.length == 0)
                    runnerWindow.visible = false;
            }
        }
    }
}

