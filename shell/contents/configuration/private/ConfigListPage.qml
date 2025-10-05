// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.configuration
import org.kde.kitemmodels as KItemModels

Kirigami.ScrollablePage {
    id: root
    property alias model1: repeater1.model
    property alias model2: repeater2.model

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    titleDelegate: RowLayout {
        // Add close button
        QQC2.ToolButton {
            Layout.leftMargin: -Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing
            icon.name: "arrow-left"
            onClicked: root.Window.window.close()
        }

        Kirigami.Heading {
            level: 1
            text: root.title
        }
    }

    signal requestOpen(var delegate)

    ColumnLayout {
        spacing: 0

        Kirigami.InlineMessage {
            Layout.alignment: Qt.AlignTop
            visible: Plasmoid.immutable
            text: i18n("Layout changes have been restricted by the system administrator")
            showCloseButton: true
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing * 2 // we need this because ColumnLayout's spacing is 0
        }

        Repeater {
            id: repeater1

            delegate: QQC2.ItemDelegate {
                icon.name: model.icon
                text: model.name
                Layout.fillWidth: true

                onClicked: root.requestOpen(model)
            }
        }

        Repeater {
            id: repeater2

            delegate: QQC2.ItemDelegate {
                icon.name: model.icon
                text: model.name
                Layout.fillWidth: true

                onClicked: root.requestOpen(model)
            }
        }
    }
}
