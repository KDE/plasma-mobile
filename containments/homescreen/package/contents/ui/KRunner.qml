/*
 * SPDX-FileCopyrightText: 2015 Vishesh Handa <vhanda@kde.org>
 *
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
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
    height: childrenRect.height
    color: listView.visible ? Qt.rgba(0, 0, 0, 0.8) : "transparent"
    property alias showingResults: listView.visible
    property int inputHeight: queryField.height + background.fixedMargins.top/2 + background.fixedMargins.bottom
    property int topPadding: 0

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
        height: Math.min(krunner.height, childrenRect.height + fixedMargins.top/2 + fixedMargins.bottom)
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
            height: Qt.inputMethod.keyboardRectangle.height > 0 ? (Math.min(implicitHeight, background.height, Qt.inputMethod.keyboardRectangle.y - plasmoid.availableScreenRect.y)) : implicitHeight + anchors.topMargin
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: background.fixedMargins.top / 2 + krunner.topPadding
                leftMargin: background.fixedMargins.left
                rightMargin: background.fixedMargins.right
            }
            PlasmaComponents.TextField {
                id: queryField
                clearButtonShown: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                Keys.onEscapePressed: runnerWindow.visible = false
                placeholderText: i18n("Search...")
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

