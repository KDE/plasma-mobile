/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Effects
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.milou as Milou
import org.kde.kirigami 2.19 as Kirigami

Item {
    id: root

    function requestFocus() {
        queryField.forceActiveFocus();
    }

    function clearField() {
        queryField.text = "";
    }

    signal requestedClose()

    ColumnLayout {
        id: column
        anchors.fill: parent

        Controls.Control {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.leftMargin: Kirigami.Units.gridUnit
            Layout.rightMargin: Kirigami.Units.gridUnit

            leftPadding: Kirigami.Units.smallSpacing
            rightPadding: Kirigami.Units.smallSpacing
            topPadding: Kirigami.Units.smallSpacing
            bottomPadding: Kirigami.Units.smallSpacing

            background: Item {

                // shadow for search window
                MultiEffect {
                    anchors.fill: parent
                    source: rectBackground
                    blurMax: 16
                    shadowEnabled: true
                    shadowVerticalOffset: 1
                    shadowOpacity: 0.15
                }

                Rectangle {
                    id: rectBackground
                    anchors.fill: parent
                    color: Kirigami.Theme.backgroundColor
                    radius: Kirigami.Units.cornerRadius
                }
            }

            contentItem: RowLayout {
                Item {
                    implicitHeight: queryField.height
                    implicitWidth: height
                    Kirigami.Icon {
                        anchors.fill: parent
                        anchors.margins: Math.round(Kirigami.Units.smallSpacing)
                        source: "start-here-symbolic"
                    }
                }
                PlasmaComponents.TextField {
                    id: queryField
                    Layout.fillWidth: true
                    placeholderText: i18n("Search…")
                    inputMethodHints: Qt.ImhNoPredictiveText // don't need to press "enter" to update text
                }
            }
        }

        Controls.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: listView.contentHeight > availableHeight

            Milou.ResultsListView {
                id: listView
                queryString: queryField.text
                clip: true
                Kirigami.Theme.colorSet: Kirigami.Theme.Window

                highlight: activeFocus ? highlightComponent : null
                Component {
                    id: highlightComponent

                    PlasmaExtras.Highlight {}
                }

                onActivated: {
                    root.requestedClose();
                }
                onUpdateQueryString: {
                    queryField.text = text
                    queryField.cursorPosition = cursorPosition
                }

                delegate: MouseArea {
                    id: delegate
                    height: rowLayout.height
                    width: listView.width

                    onClicked: {
                        listView.currentIndex = model.index;
                        listView.runCurrentIndex();

                        root.requestedClose();
                    }
                    hoverEnabled: true

                    function activateNextAction() {
                        queryField.forceActiveFocus();
                        queryField.selectAll();
                        listView.currentIndex = -1;
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: delegate.pressed ? Qt.rgba(255, 255, 255, 0.2) : (delegate.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
                        Behavior on color {
                            ColorAnimation { duration: Kirigami.Units.shortDuration }
                        }
                    }

                    RowLayout {
                        id: rowLayout
                        height: Kirigami.Units.gridUnit * 3
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            leftMargin: Kirigami.Units.gridUnit
                            rightMargin: Kirigami.Units.gridUnit
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

                        Repeater {
                            id: actionsRepeater
                            model: typeof actions !== "undefined" ? actions : []

                            Controls.ToolButton {
                                icon: modelData.icon || ""
                                visible: modelData.visible || true
                                enabled: modelData.enabled || true

                                Accessible.role: Accessible.Button
                                Accessible.name: modelData.text
                                checkable: checked
                                checked: delegate.activeAction === index
                                focus: delegate.activeAction === index
                                onClicked: delegate.ListView.view.runAction(index)
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            Layout.fillWidth: true
            Layout.fillHeight: true

            onClicked: root.requestedClose()
        }
    }
}
