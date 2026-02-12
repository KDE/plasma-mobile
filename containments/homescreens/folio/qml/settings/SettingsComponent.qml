// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

import '../delegate'

Item {
    id: root
    property Folio.HomeScreen folio

    property var homeScreen
    property real settingsModeHomeScreenScale

    readonly property bool homeScreenInteractive: !appletListViewer.active

    property real bottomMargin: 0
    property real leftMargin: 0
    property real rightMargin: 0

    MouseArea {
        id: closeSettings

        onClicked: {
            folio.HomeScreenState.closeSettingsView();
        }
    }

    Item {
        id: settingsBar

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        anchors.bottomMargin: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? Kirigami.Units.largeSpacing + Math.round(root.bottomMargin / 2) : 0
        anchors.rightMargin: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right ? Kirigami.Units.largeSpacing + Math.round(root.rightMargin / 2) : 0
        anchors.leftMargin: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left ? Kirigami.Units.largeSpacing + Math.round(root.leftMargin / 2) : 0

        GridLayout {
            id: settingsOptions
            flow: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? GridLayout.LeftToRight : GridLayout.TopToBottom
            uniformCellWidths: true

            anchors.centerIn: parent

            SettingsButton {
                iconName: 'edit-image'
                textLabel: i18n("Wallpapers")
                onClicked: {
                    root.homeScreen.wallpaperSelectorTriggered();
                    folio.HomeScreenState.closeSettingsView();
                }
            }

            SettingsButton {
                iconName: 'settings-configure'
                textLabel: i18n("Settings")
                onClicked: {
                    root.homeScreen.openConfigure()
                }
            }

            SettingsButton {
                iconName: 'widget-alternatives'
                textLabel: i18n("Widgets")
                onClicked: {
                    appletListViewer.active = true;
                }
            }
        }
    }

    states: [
        State {
            name: "bottom"
            when: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom
            PropertyChanges {
                target: settingsBar
                height: root.height * (1 - root.settingsModeHomeScreenScale)
            }
            AnchorChanges {
                target: settingsBar
                anchors.top: undefined
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
            AnchorChanges {
                target: closeSettings
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: settingsBar.top
            }
        }, State {
            name: "left"
            when: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Left
            PropertyChanges {
                target: settingsBar
                width: root.width * (1 - root.settingsModeHomeScreenScale)
            }
            AnchorChanges {
                target: settingsBar
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: undefined
            }
            AnchorChanges {
                target: closeSettings
                anchors.top: parent.top
                anchors.left: settingsBar.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }, State {
            name: "right"
            when: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Right
            PropertyChanges {
                target: settingsBar
                width: root.width * (1 - root.settingsModeHomeScreenScale)
            }
            AnchorChanges {
                target: settingsBar
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: undefined
                anchors.right: parent.right
            }
            AnchorChanges {
                target: closeSettings
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: settingsBar.left
                anchors.bottom: parent.bottom
            }
        }
    ]

    AppletListViewer {
        id: appletListViewer

        width: parent.width
        height: parent.height

        folio: root.folio
        homeScreen: root.homeScreen
    }
}
