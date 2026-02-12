// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell

Item {
    id: root

    property real leftMargin
    property real rightMargin
    property real bottomMargin
    property var homeScreen

    MouseArea {
        id: closeSettings

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: settingsBar.top

        onClicked: {
            root.homeScreen.settingsOpen = false;
        }
    }

    Item {
        id: settingsBar
        height: settingsOptions.implicitHeight

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        anchors.left: parent.left
        anchors.leftMargin: root.leftMargin
        anchors.right: parent.right
        anchors.rightMargin: parent.rightMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing + root.bottomMargin

        RowLayout {
            id: settingsOptions
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Kirigami.Units.largeSpacing

            PC3.ToolButton {
                opacity: 0.9
                implicitHeight: Kirigami.Units.gridUnit * 4
                implicitWidth: Kirigami.Units.gridUnit * 5

                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        source: 'edit-image'
                    }

                    QQC2.Label {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        text: i18n("Wallpapers")
                        font.bold: true
                    }
                }

                onClicked: {
                    root.homeScreen.settingsOpen = false;
                    root.homeScreen.wallpaperSelectorTriggered();
                }
            }

            PC3.ToolButton {
                opacity: 0.9
                implicitHeight: Kirigami.Units.gridUnit * 4
                implicitWidth: Kirigami.Units.gridUnit * 5

                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        source: 'settings-configure'
                    }

                    QQC2.Label {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        text: i18n("Settings")
                        font.bold: true
                    }
                }

                onClicked: {
                    root.homeScreen.settingsOpen = false;
                    root.homeScreen.openContainmentSettings();
                }
            }
        }
    }
}
