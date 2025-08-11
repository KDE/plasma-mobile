/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Effects
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.milou as Milou
import org.kde.kirigami 2.19 as Kirigami

MouseArea {
    id: root
    onClicked: root.requestedClose(false)

    function requestFocus() {
        queryField.forceActiveFocus();
    }

    function clearField() {
        queryField.text = "";
    }

    signal requestedClose(triggeredByKeyEvent: bool)

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            root.requestedClose(true);
            event.accepted = true;
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent

        Kirigami.SearchField {
            id: queryField
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.leftMargin: Kirigami.Units.gridUnit
            Layout.rightMargin: Kirigami.Units.gridUnit

            background: Rectangle {
                radius: Kirigami.Units.cornerRadius
                color: Qt.rgba(255, 255, 255, (queryField.hovered || queryField.focus) ? 0.2 : 0.1)

                Behavior on color { ColorAnimation {} }
            }

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

            topPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
            bottomPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing

            placeholderText: i18nc("@info:placeholder", "Search…")
            placeholderTextColor: Qt.rgba(255, 255, 255, 0.8)
            color: 'white'
            inputMethodHints: Qt.ImhNoPredictiveText // don't need to press "enter" to update text

            font.weight: Font.Bold

            // Keyboard navigation
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Down) {
                    if (listView.count === 0) {
                        // Close if listview has no elements
                        root.requestedClose(true);
                    } else {
                        // Focus on listview if there are elements
                        listView.forceActiveFocus();
                        listView.currentIndex = 0;
                    }
                    event.accepted = true;
                }
            }

        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: listView.contentHeight > availableHeight

            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            Layout.leftMargin: Kirigami.Units.gridUnit
            Layout.rightMargin: Kirigami.Units.gridUnit
            Layout.alignment: Qt.AlignHCenter

            Milou.ResultsListView {
                id: listView
                queryString: queryField.text
                clip: true

                highlight: activeFocus ? highlightComponent : null
                Component {
                    id: highlightComponent

                    PlasmaExtras.Highlight {}
                }

                onActivated: {
                    root.requestedClose(false);
                }
                onUpdateQueryString: {
                    queryField.text = text
                    queryField.cursorPosition = cursorPosition
                }

                section.delegate: QQC2.Control {
                    id: sectionHeader
                    required property string section

                    topPadding: Kirigami.Units.smallSpacing
                    bottomPadding: Kirigami.Units.smallSpacing
                    leftPadding: 0
                    rightPadding: 0

                    contentItem: Kirigami.Heading {
                        opacity: 0.7
                        level: 5
                        type: Kirigami.Heading.Primary
                        text: sectionHeader.section
                        elide: Text.ElideRight
                        color: 'white'

                        // we override the Primary type's font weight (DemiBold) for Bold for contrast with small text
                        font.weight: Font.Bold
                        Accessible.ignored: true
                    }
                }


                delegate: MouseArea {
                    id: delegate
                    height: rowLayout.height
                    width: listView.width

                    // Go to search bar if this we press up with the first item selected
                    KeyNavigation.up: model.index === 0 ? queryField : null

                    // Close search view if we press down with last item selected
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Down && (model.index === listView.count - 1)) {
                            root.requestedClose(true);
                            event.accepted = true;
                        }
                    }

                    // Used by ResultsListView to determine next tab action
                    function activateNextAction() {
                        queryField.forceActiveFocus();
                        queryField.selectAll();
                        listView.currentIndex = -1;
                    }

                    onClicked: {
                        listView.currentIndex = model.index;
                        listView.runCurrentIndex();

                        root.requestedClose(false);
                    }
                    hoverEnabled: true

                    Rectangle {
                        anchors.fill: parent
                        radius: Kirigami.Units.cornerRadius
                        color: delegate.pressed ? Qt.rgba(255, 255, 255, 0.3) : (delegate.containsMouse ? Qt.rgba(255, 255, 255, 0.1) : "transparent")
                    }

                    RowLayout {
                        id: rowLayout
                        height: Kirigami.Units.gridUnit * 3
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            leftMargin: Kirigami.Units.largeSpacing
                            rightMargin: Kirigami.Units.largeSpacing
                        }

                        Kirigami.Icon {
                            Layout.alignment: Qt.AlignVCenter
                            source: model.decoration
                            implicitWidth: Kirigami.Units.iconSizes.medium
                            implicitHeight: Kirigami.Units.iconSizes.medium
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Kirigami.Units.smallSpacing

                            PlasmaComponents.Label {
                                id: title
                                Layout.fillWidth: true
                                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                                Layout.rightMargin: Kirigami.Units.gridUnit

                                maximumLineCount: 1
                                elide: Text.ElideRight
                                text: typeof modelData !== "undefined" ? modelData : model.display
                                color: "white"

                                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                            }
                            PlasmaComponents.Label {
                                id: subtitle
                                Layout.fillWidth: true
                                Layout.leftMargin: Kirigami.Units.smallSpacing * 2
                                Layout.rightMargin: Kirigami.Units.gridUnit

                                maximumLineCount: 1
                                elide: Text.ElideRight
                                text: model.subtext || ""
                                color: "white"
                                opacity: 0.8

                                font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 0.8)
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
