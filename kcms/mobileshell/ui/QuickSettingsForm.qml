/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

FormCard.FormCardPage {
    id: root

    title: i18n("Quick Settings")

    component Delegate : FormCard.AbstractFormDelegate {
        id: qsDelegate

        property bool isEnabled: false

        width: ListView.view.width

        background: null
        contentItem: RowLayout {
            Kirigami.ListItemDragHandle {
                visible: qsDelegate.isEnabled
                Layout.rightMargin: Kirigami.Units.largeSpacing
                listItem: qsDelegate
                listView: qsDelegate.ListView.view
                onMoveRequested: savedQuickSettings.enabledModel.moveRow(oldIndex, newIndex)
            }

            Kirigami.Icon {
                readonly property bool iconAvailable: model && model.icon !== ""

                visible: iconAvailable
                source: model ? model.icon : ""
                Layout.rightMargin: iconAvailable ? Kirigami.Units.gridUnit : 0
                implicitWidth: iconAvailable ? Kirigami.Units.iconSizes.small : 0
                implicitHeight: iconAvailable ? Kirigami.Units.iconSizes.small : 0
            }

            QQC2.Label {
                Layout.fillWidth: true
                text: model ? model.name : ""
                elide: Text.ElideRight
            }

            QQC2.ToolButton {
                display: QQC2.AbstractButton.IconOnly
                text: qsDelegate.isEnabled ? i18nc("@action:button", "Hide") : i18nc("@action:button", "Show")
                icon.name: qsDelegate.isEnabled ? "hide_table_row" : "show_table_row"
                onClicked: qsDelegate.isEnabled ? savedQuickSettings.disableQS(model.index) : savedQuickSettings.enableQS(model.index)

                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: text
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            }
        }
    }

    data: QS.SavedQuickSettings {
        id: savedQuickSettings
    }

    FormCard.FormHeader {
        title: i18n("Quick Settings")
        visible: enabledRepeater.count > 0
    }

    FormCard.FormCard {
        FormCard.FormComboBoxDelegate {
            id: statusBarScaleFactorDelegate

            text: i18n("Quick Settings Columns")
            description: i18n("Maximum number of columns in landscape orientation.")

            model: [3, 4, 5, 6]

            Component.onCompleted: {
                currentIndex = indexOfValue(ShellSettings.Settings.quickSettingsColumns);
                dialog.parent = root;
            }
            onCurrentValueChanged: ShellSettings.Settings.quickSettingsColumns = currentValue
        }
    }

    FormCard.FormSectionText {
        text: i18n("Customize the order of quick settings in the pull-down panel and hide them.")
        visible: enabledRepeater.count > 0
    }

    FormCard.FormCard {
        visible: enabledRepeater.count > 0

        ListView {
            id: enabledRepeater

            interactive: false

            model: savedQuickSettings.enabledModel
            delegate: Delegate {
                isEnabled: true
            }

            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
        }
    }

    FormCard.FormHeader {
        title: i18n("Disabled Quick Settings")
        visible: disabledRepeater.count > 0
    }

    FormCard.FormSectionText {
        text: i18n("Re-enable previously disabled quick settings.")
        visible: disabledRepeater.count > 0
    }

    FormCard.FormCard {
        visible: disabledRepeater.count > 0

        ListView {
            id: disabledRepeater

            interactive: false

            model: savedQuickSettings.disabledModel
            delegate: Delegate {
                isEnabled: false
            }

            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
        }
    }
}

