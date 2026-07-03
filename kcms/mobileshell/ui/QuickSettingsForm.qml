/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

FormCard.FormCardPage {
    id: root

    title: i18n("Quick Settings")

    Component {
        id: delegateComponent

        FormCard.AbstractFormDelegate {
            id: qsDelegate
            z: dragHandle.dragActive ? 100 : 0

            property string itemIcon: ""
            property string itemName: ""
            property int index: 0
            property ListView targetView: null
            property bool isEnabled: true

            readonly property bool iconAvailable: qsDelegate.itemIcon !== ""

            RectangularShadow {
                anchors.fill: background
                offset.y: 1
                blur: 12
                spread: 6
                color: "black"
                opacity: dragHandle.dragActive ? 0.2 : 0
                z: -10

                Behavior on opacity {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.OutQuint
                    }
                }

            }

            background: Rectangle {
                id: background
                anchors.fill: parent
                color: Kirigami.Theme.backgroundColor
            }
            contentItem: RowLayout {
                Kirigami.ListItemDragHandle {
                    id: dragHandle
                    visible: qsDelegate.isEnabled
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    listItem: qsDelegate
                    listView: qsDelegate.targetView

                    onMoveRequested: (oldIndex, newIndex) => {
                        savedQuickSettings.enabledModel.moveRow(oldIndex, newIndex);
                    }
                }

                Kirigami.Icon {
                    visible: qsDelegate.iconAvailable
                    source: qsDelegate.itemIcon
                    Layout.rightMargin: qsDelegate.iconAvailable ? Kirigami.Units.gridUnit : 0
                    implicitWidth: qsDelegate.iconAvailable ? Kirigami.Units.iconSizes.small : 0
                    implicitHeight: qsDelegate.iconAvailable ? Kirigami.Units.iconSizes.small : 0
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: qsDelegate.itemName
                    elide: Text.ElideRight
                }

                QQC2.ToolButton {
                    display: QQC2.AbstractButton.IconOnly
                    text: qsDelegate.isEnabled ? i18nc("@action:button", "Hide") : i18nc("@action:button", "Show")
                    icon.name: qsDelegate.isEnabled ? "hide_table_row" : "show_table_row"
                    onClicked: qsDelegate.isEnabled ? savedQuickSettings.disableQS(qsDelegate.index) : savedQuickSettings.enableQS(qsDelegate.index)

                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: text
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                }
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

            delegate: Loader {
                id: enabledLoader
                width: enabledRepeater.width
                sourceComponent: delegateComponent

                readonly property string itemIcon: model.icon
                readonly property string itemName: model.name
                readonly property int itemIndex: index
                readonly property bool isEnabled: true
                readonly property ListView targetView: enabledRepeater

                Binding { target: enabledLoader.item; property: "itemIcon"; value: enabledLoader.itemIcon; when: enabledLoader.item !== null }
                Binding { target: enabledLoader.item; property: "itemName"; value: enabledLoader.itemName; when: enabledLoader.item !== null }
                Binding { target: enabledLoader.item; property: "index"; value: enabledLoader.itemIndex; when: enabledLoader.item !== null }
                Binding { target: enabledLoader.item; property: "targetView"; value: enabledLoader.targetView; when: enabledLoader.item !== null }
                Binding { target: enabledLoader.item; property: "isEnabled"; value: enabledLoader.isEnabled; when: enabledLoader.item !== null }
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

            delegate: Loader {
                id: disabledLoader
                width: disabledRepeater.width
                sourceComponent: delegateComponent

                readonly property string itemIcon: model.icon
                readonly property string itemName: model.name
                readonly property int itemIndex: index
                readonly property bool isEnabled: false
                readonly property ListView targetView: disabledRepeater

                Binding { target: disabledLoader.item; property: "itemIcon"; value: disabledLoader.itemIcon; when: disabledLoader.item !== null }
                Binding { target: disabledLoader.item; property: "itemName"; value: disabledLoader.itemName; when: disabledLoader.item !== null }
                Binding { target: disabledLoader.item; property: "index"; value: disabledLoader.itemIndex; when: disabledLoader.item !== null }
                Binding { target: disabledLoader.item; property: "targetView"; value: disabledLoader.targetView; when: disabledLoader.item !== null }
                Binding { target: disabledLoader.item; property: "isEnabled"; value: disabledLoader.isEnabled; when: disabledLoader.item !== null }
            }

            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
        }
    }
}

