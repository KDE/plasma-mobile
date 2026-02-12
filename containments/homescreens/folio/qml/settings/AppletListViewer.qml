// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.shell 2.0
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell as MobileShell

import '../delegate'
import '../private'

Loader {
    id: root
    property Folio.HomeScreen folio

    property var homeScreen

    active: false

    function requestClose() {
        active = false;
    }

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    sourceComponent: Item {
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.7)
        }

        PlasmaExtras.ModelContextMenu {
            id: getWidgetsDialog
            visualParent: getWidgetsButton
            placement: PlasmaExtras.Menu.TopPosedLeftAlignedPopup
            // model set on first invocation
            onClicked: model.trigger()
        }

        RowLayout {
            id: header
            spacing: Kirigami.Units.largeSpacing
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.gridUnit
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.gridUnit * 3 + root.homeScreen.topMargin
            anchors.right: parent.right
            anchors.rightMargin: Kirigami.Units.gridUnit

            PC3.ToolButton {
                Layout.alignment: Qt.AlignVCenter
                icon.name: 'go-previous'
                implicitWidth: Kirigami.Units.gridUnit * 2
                implicitHeight: Kirigami.Units.gridUnit * 2
                padding: Kirigami.Units.smallSpacing
                onClicked: root.requestClose()
            }

            PC3.Label {
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                text: i18n("Widgets")
                wrapMode: Text.Wrap
                font.weight: Font.Bold
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
                Layout.fillWidth: true
            }

            PC3.ToolButton {
                id: getWidgetsButton
                icon.name: "get-hot-new-stuff"
                text: i18ndc("plasma_shell_org.kde.plasma.mobile", "@action:button The word 'new' refers to widgets", "Get New Widgets…")
                Accessible.name: i18ndc("plasma_shell_org.kde.plasma.mobile", "@action:button", "Get New Widgets…")

                onClicked: {
                    getWidgetsDialog.model = widgetExplorer.widgetsMenuActions
                    getWidgetsDialog.openRelative()
                }
            }
        }

        GridView {
            id: gridView
            clip: true
            reuseItems: true

            opacity: 0 // we display with the opacity gradient below

            anchors.top: header.bottom
            anchors.topMargin: Kirigami.Units.gridUnit
            anchors.left: parent.left
            anchors.leftMargin: root.homeScreen.leftMargin
            anchors.right: parent.right
            anchors.rightMargin: root.homeScreen.rightMargin
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.homeScreen.bottomMargin

            model: widgetExplorer.widgetsModel

            readonly property real intendedCellWidth: Kirigami.Units.gridUnit * 8
            readonly property int columns: Math.min(5, (width - leftMargin - rightMargin) / intendedCellWidth)

            cellWidth: (width - leftMargin - rightMargin) / columns
            cellHeight: cellWidth + Kirigami.Units.gridUnit * 3

            readonly property real horizontalMargin: Math.round(width * 0.05)
            leftMargin: horizontalMargin
            rightMargin: horizontalMargin

            delegate: AppletListDelegate {
                folio: root.folio
                width: gridView.cellWidth
                height: gridView.cellHeight
            }
        }

        // opacity gradient at grid edges
        MobileShell.FlickableOpacityGradient {
            anchors.fill: gridView
            flickable: gridView
        }

        WidgetExplorer {
            id: widgetExplorer
            containment: Plasmoid

            onShouldClose: root.requestClose()
        }
    }
}
