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

    readonly property bool homeScreenInteractive: !appletListViewerLoader.active

    property real bottomMargin: 0
    property real leftMargin: 0
    property real rightMargin: 0

    Connections {
        target: folio.HomeScreenState

        // Close applet viewer when settings view closes
        function onViewStateChanged() {
            if (folio.HomeScreenState.viewState !== Folio.HomeScreenState.SettingsView) {
                appletListViewerLoader.requestClose();
            }
        }
    }

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

            anchors.centerIn: parent

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
                        text: i18n('Wallpapers')
                        font.bold: true
                    }
                }

                onClicked: {
                    homeScreen.wallpaperSelectorTriggered();
                    folio.HomeScreenState.closeSettingsView();
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
                        text: i18n('Settings')
                        font.bold: true
                    }
                }

                onClicked: {
                    // ensure that if the window is already opened, it gets raised to the top
                    settingsWindow.hide();
                    settingsWindow.showMaximized();
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
                        source: 'widget-alternatives'
                    }

                    QQC2.Label {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        text: i18n('Widgets')
                        font.bold: true
                    }
                }

                onClicked: {
                    appletListViewerLoader.active = true;
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

    Loader {
        id: appletListViewerLoader
        asynchronous: true
        active: false

        signal requestClose()
        onRequestClose: item?.requestClose()

        width: parent.width
        height: parent.height

        opacity: status == Loader.Ready ? 1 : 0
        // move the settings out of the way if it is not visible
        // NOTE: we do this instead of setting visible to false, because
        //       it doesn't mess with widget drag and drop
        y: (opacity > 0) ? 0 : parent.height

        Behavior on opacity {
            NumberAnimation { duration: Kirigami.Units.shortDuration }
        }

        sourceComponent: AppletListViewer {
            id: appletListViewer
            folio: root.folio

            width: parent.width
            height: parent.height

            onRequestClose: parent.active = false

            homeScreen: root.homeScreen
        }
    }

    PC3.BusyIndicator {
        id: appletListLoadingIndicator
        anchors.centerIn: parent
        visible: appletListViewerLoader.status === Loader.Loading

        implicitHeight: Kirigami.Units.iconSizes.huge
        implicitWidth: Kirigami.Units.iconSizes.huge

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    }

    SettingsWindow {
        id: settingsWindow
        folio: root.folio
        visible: false

        onRequestConfigureMenu: {
            homeScreen.openConfigure()
        }
    }
}
