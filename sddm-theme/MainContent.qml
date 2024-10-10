// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.notificationmanager as Notifications
import org.kde.plasma.private.mobileshell as MobileShell

Item {
    id: root

    required property bool isVertical
    property real fullHeight

    property var greeterState

    SessionButton {
        id: sessionButton
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.gridUnit
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.gridUnit

        onCurrentIndexChanged: root.greeterState.sessionIndex = currentIndex
    }

    // Vertical layout
    ColumnLayout {
        id: verticalLayout
        visible: root.isVertical
        spacing: 0

        // Center clock when no notifications are shown, otherwise move the clock upward
        anchors.topMargin: Math.round(Kirigami.Units.gridUnit * 3.5)
        anchors.bottomMargin: Kirigami.Units.gridUnit * 2
        anchors.fill: parent

        LayoutItemProxy { target: clockWidget }
        LayoutItemProxy { target: userSwitcher }
    }

    // Horizontal layout (landscape on smaller devices)
    Item {
        id: horizontalLayout
        anchors.fill: parent
        visible: !root.isVertical

        ColumnLayout {
            id: leftLayout
            width: Math.round(parent.width / 2)
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                leftMargin: Kirigami.Units.gridUnit * 3
            }

            LayoutItemProxy { target: clockWidget }
        }

        ColumnLayout {
            id: rightLayout
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: leftLayout.right
                right: parent.right
                rightMargin: Kirigami.Units.gridUnit
            }

            LayoutItemProxy { target: userSwitcher }
        }
    }

    // Clock and media widget column
    ColumnLayout {
        id: clockWidget
        Layout.fillWidth: true
        Layout.fillHeight: root.isVertical
        spacing: Kirigami.Units.gridUnit

        Clock {
            layoutAlignment: root.isVertical ? Qt.AlignHCenter : Qt.AlignLeft
            Layout.alignment: root.isVertical ? Qt.AlignHCenter : Qt.AlignLeft
            Layout.fillWidth: true
        }
    }

    ColumnLayout {
        id: userSwitcher

        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * (25 + 2) // clip margins

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true

            // clip: true
            focus: true
            spacing: Kirigami.Units.smallSpacing

            model: userModel
            orientation: ListView.Horizontal
            currentIndex: userModel.lastIndex

            delegate: QQC2.Control {
                id: control
                required property string realName
                required property string name
                required property string icon
                required property bool needsPassword

                implicitHeight: Kirigami.Units.gridUnit * 5
                implicitWidth: listView.width

                anchors.verticalCenter: parent.verticalCenter

                topPadding: Kirigami.Units.largeSpacing
                bottomPadding: Kirigami.Units.largeSpacing
                leftPadding: Kirigami.Units.largeSpacing
                rightPadding: Kirigami.Units.largeSpacing

                background: Rectangle {
                    color: Qt.rgba(255, 255, 255, 0.2)
                    radius: Kirigami.Units.cornerRadius
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.3)
                }

                contentItem: RowLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Image {
                        source: control.icon
                        Layout.fillHeight: true
                        width: height
                    }

                    QQC2.Label {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        text: control.name
                        font.bold: true
                        font.pointSize: 16
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index;
                        listView.focus = true;
                    }
                }
            }
        }
    }
}
