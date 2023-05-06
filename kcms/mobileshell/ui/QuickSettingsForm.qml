/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.3 as KCM
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

Kirigami.ScrollablePage {
    id: root
    title: i18n("Quick Settings")
    leftPadding: 0
    rightPadding: 0
    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    
    Component {
        id: listItemComponent

        MobileForm.AbstractFormDelegate {
            id: qsDelegate

            readonly property bool isEnabled: parent ? parent.parentView.isEnabled : false

            contentItem: RowLayout {
                Kirigami.ListItemDragHandle {
                    visible: qsDelegate.isEnabled
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    listItem: qsDelegate
                    listView: qsDelegate.parent ? qsDelegate.parent.parentView : null
                    onMoveRequested: savedQuickSettings.enabledModel.moveRow(oldIndex, newIndex)
                }

                Kirigami.Icon {
                    readonly property bool iconAvailable: model && model.icon !== ""

                    visible: iconAvailable
                    source: model ? model.icon : ""
                    Layout.rightMargin: iconAvailable ? Kirigami.Units.largeSpacing : 0
                    implicitWidth: iconAvailable ? Kirigami.Units.iconSizes.small : 0
                    implicitHeight: iconAvailable ? Kirigami.Units.iconSizes.small : 0
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: model ? model.name : ""
                        elide: Text.ElideRight
                    }
                }

                QQC2.ToolButton {
                    icon.name: model ? qsDelegate.isEnabled ? "hide_table_row" : "show_table_row" : ""
                    onClicked: qsDelegate.isEnabled ? savedQuickSettings.disableQS(model.index) : savedQuickSettings.enableQS(model.index)
                }
            }
        }
    }

    Component {
        id: listViewComponent

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            interactive: false

            property bool isEnabled: false
            model: isEnabled ? savedQuickSettings.enabledModel : savedQuickSettings.disabledModel

            moveDisplaced: Transition {
                YAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            delegate: Kirigami.DelegateRecycler {
                id: delegate

                width: listView.width
                sourceComponent: listItemComponent

                readonly property ListView parentView: ListView.view
            }
        }
    }

    QS.SavedQuickSettings {
        id: savedQuickSettings
    }

    ColumnLayout {
        spacing: Kirigami.Units.smallSpacing
        width: root.width
        
        MobileForm.FormCard {
            Layout.fillWidth: true
            
            contentItem: ColumnLayout {
                spacing: 0
                
                MobileForm.FormCardHeader {
                    title: i18n("Quick Settings")
                    subtitle: i18n("Customize the order of quick settings in the pull-down panel and hide them.")
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.preferredHeight: item ? item.contentHeight : 0

                    asynchronous: true
                    sourceComponent: listViewComponent

                    onLoaded: item.isEnabled = true
                }
            }
        }

        MobileForm.FormCard {
            Layout.fillWidth: true

            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormCardHeader {
                    title: i18n("Disabled Quick Settings")
                    subtitle: i18n("Re-enable previously disabled quick settings.")
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.preferredHeight: item ? item.contentHeight : 0

                    asynchronous: true
                    sourceComponent: listViewComponent

                    onLoaded: item.isEnabled = false
                }
            }
        }
    }
}

