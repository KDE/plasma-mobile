// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami

import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.kirigamiaddons.formcard 1.0 as FormCard

import '../delegate'

Window {
    id: root
    flags: Qt.FramelessWindowHint
    color: 'transparent'

    onVisibleChanged: {
        if (visible) {
            opacityAnim.to = 1;
            opacityAnim.restart();
        }
    }

    onClosing: (close) => {
        if (applicationItem.opacity !== 0) {
            close.accepted = false;
            opacityAnim.to = 0;
            opacityAnim.restart();
        }
    }

    signal requestConfigureMenu()

    Kirigami.ApplicationItem {
        id: applicationItem
        anchors.fill: parent

        opacity: 0

        NumberAnimation on opacity {
            id: opacityAnim
            duration: 200
            easing.type: Easing.OutCubic
            onFinished: {
                if (applicationItem.opacity === 0) {
                    root.close();
                }
            }
        }

        scale: 0.7 + 0.3 * applicationItem.opacity

        pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
        pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons;

        pageStack.initialPage: Kirigami.ScrollablePage {
            id: page
            opacity: applicationItem.opacity

            titleDelegate: RowLayout {
                QQC2.ToolButton {
                    Layout.leftMargin: -Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing
                    icon.name: "arrow-left"
                    onClicked: root.close()
                }

                Kirigami.Heading {
                    level: 1
                    text: page.title
                }
            }

            title: i18n("Homescreen Settings")

            topPadding: 0
            bottomPadding: 0
            leftPadding: 0
            rightPadding: 0

            ColumnLayout {
                FormCard.FormHeader {
                    title: i18n("Icons")
                }

                FormCard.FormCard {
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

                    Item {
                        Layout.preferredHeight: Folio.HomeScreenState.pageCellHeight
                        Layout.fillWidth: true

                        AbstractDelegate {
                            anchors.centerIn: parent
                            implicitHeight: Folio.HomeScreenState.pageCellHeight
                            implicitWidth: Folio.HomeScreenState.pageCellWidth
                            name: i18n('Application')

                            contentItem: DelegateAppIcon {
                                height: Folio.FolioSettings.delegateIconSize
                                width: Folio.FolioSettings.delegateIconSize
                                source: 'applications-system'
                            }
                        }
                    }
                }

                FormCard.FormCard {
                    id: iconsCard
                    readonly property bool isVerticalOrientation: Folio.HomeScreenState.pageOrientation === Folio.HomeScreenState.RegularPosition ||
                                                                Folio.HomeScreenState.pageOrientation === Folio.HomeScreenState.RotateUpsideDown

                    readonly property string numOfRowsText: i18n("Number of rows")
                    readonly property string numOfColumnsText: i18n("Number of columns")

                    FormCard.FormSpinBoxDelegate {
                        id: iconSizeSpinBox
                        label: i18n("Size of icons on homescreen")
                        from: 16
                        to: 128
                        value: Folio.FolioSettings.delegateIconSize
                        onValueChanged: {
                            if (value !== Folio.FolioSettings.delegateIconSize) {
                                Folio.FolioSettings.delegateIconSize = value;
                            }
                        }
                    }

                    FormCard.FormSpinBoxDelegate {
                        id: rowsSpinBox
                        label: iconsCard.isVerticalOrientation ? iconsCard.numOfRowsText : iconsCard.numOfColumnsText
                        from: 3
                        to: 10
                        value: Folio.FolioSettings.homeScreenRows
                        onValueChanged: {
                            if (value !== Folio.FolioSettings.homeScreenRows) {
                                Folio.FolioSettings.homeScreenRows = value;
                            }
                        }
                    }

                    FormCard.FormSpinBoxDelegate {
                        id: columnsSpinBox
                        label: iconsCard.isVerticalOrientation ? iconsCard.numOfColumnsText : iconsCard.numOfRowsText
                        from: 3
                        to: 10
                        value: Folio.FolioSettings.homeScreenColumns
                        onValueChanged: {
                            if (value !== Folio.FolioSettings.homeScreenColumns) {
                                Folio.FolioSettings.homeScreenColumns = value;
                            }
                        }
                    }
                }

                FormCard.FormSectionText {
                    text: i18n("The rows and columns will swap depending on the screen rotation.")
                }

                FormCard.FormHeader {
                    title: i18n("Homescreen")
                }

                FormCard.FormCard {
                    FormCard.FormSwitchDelegate {
                        id: showLabelsOnHomeScreen
                        text: i18n("Show labels on homescreen")
                        checked: Folio.FolioSettings.showPagesAppLabels
                        onCheckedChanged: {
                            if (checked != Folio.FolioSettings.showPagesAppLabels) {
                                Folio.FolioSettings.showPagesAppLabels = checked;
                            }
                        }
                    }

                    FormCard.FormDelegateSeparator { above: showLabelsOnHomeScreen; below: showLabelsInFavourites }

                    FormCard.FormSwitchDelegate {
                        id: showLabelsInFavourites
                        text: i18n("Show labels in favorites bar")
                        checked: Folio.FolioSettings.showFavouritesAppLabels
                        onCheckedChanged: {
                            if (checked != Folio.FolioSettings.showFavouritesAppLabels) {
                                Folio.FolioSettings.showFavouritesAppLabels = checked;
                            }
                        }
                    }

                    FormCard.FormDelegateSeparator { above: showLabelsInFavourites; below: pageTransitionCombobox }

                    FormCard.FormComboBoxDelegate {
                        id: pageTransitionCombobox
                        text: i18n("Page transition effect")

                        currentIndex: indexOfValue(Folio.FolioSettings.pageTransitionEffect)
                        model: ListModel {
                            // we can't use i18n with ListElement
                            Component.onCompleted: {
                                append({"name": i18n("Slide"), "value": Folio.FolioSettings.SlideTransition});
                                append({"name": i18n("Cube"), "value": Folio.FolioSettings.CubeTransition});
                                append({"name": i18n("Fade"), "value": Folio.FolioSettings.FadeTransition});
                                append({"name": i18n("Stack"), "value": Folio.FolioSettings.StackTransition});
                                append({"name": i18n("Rotation"), "value": Folio.FolioSettings.RotationTransition});

                                // indexOfValue doesn't bind to model changes unfortunately, set currentIndex manually here
                                pageTransitionCombobox.currentIndex = pageTransitionCombobox.indexOfValue(Folio.FolioSettings.pageTransitionEffect)
                            }
                        }

                        textRole: "name"
                        valueRole: "value"

                        onCurrentValueChanged: Folio.FolioSettings.pageTransitionEffect = currentValue
                    }
                }

                FormCard.FormHeader {
                    title: i18n("Favorites Bar")
                }

                FormCard.FormCard {
                    FormCard.FormSwitchDelegate {
                        text: i18n('Show background')
                        icon.name: 'draw-rectangle'
                        checked: Folio.FolioSettings.showFavouritesBarBackground
                        onCheckedChanged: {
                            if (checked !== Folio.FolioSettings.showFavouritesBarBackground) {
                                Folio.FolioSettings.showFavouritesBarBackground = checked;
                            }
                        }
                    }
                }

                FormCard.FormHeader {
                    title: i18n("General")
                }

                FormCard.FormCard {
                    Layout.bottomMargin: Kirigami.Units.gridUnit
                    FormCard.FormButtonDelegate {
                        id: containmentSettings
                        text: i18n('Switch Homescreen')
                        icon.name: 'settings-configure'
                        onClicked: root.requestConfigureMenu()
                    }

                    FormCard.FormDelegateSeparator { above: containmentSettings; below: exportSettings }

                    FormCard.FormButtonDelegate {
                        id: exportSettings
                        text: i18n('Export layout')
                        icon.name: 'document-export'
                        onClicked: exportFileDialog.open()
                    }

                    FormCard.FormDelegateSeparator { above: exportSettings; below: importSettings }

                    FormCard.FormButtonDelegate {
                        id: importSettings
                        text: i18n('Import layout')
                        icon.name: 'document-import'
                        onClicked: importFileDialog.open()
                    }
                }
            }

            FileDialog {
                id: exportFileDialog
                title: i18n("Export layout to")
                fileMode: FileDialog.SaveFile
                defaultSuffix: 'json'
                nameFilters: ["JSON files (*.json)"]
                onAccepted: {
                    console.log('saving layout to ' + selectedFile);
                    if (selectedFile) {
                        let status = Folio.FolioSettings.saveLayoutToFile(selectedFile);
                        if (status) {
                            exportedSuccessfullyPrompt.open();
                        } else {
                            exportFailedPrompt.open();
                        }
                    }
                }
            }

            FileDialog {
                id: importFileDialog
                fileMode: FileDialog.OpenFile
                nameFilters: ["JSON files (*.json)"]
                onAccepted: {
                    console.log('about to load layout from ' + selectedFile);
                    confirmImportPrompt.open();
                }
            }

            Kirigami.PromptDialog {
                id: exportFailedPrompt
                title: i18n("Export Status")
                subtitle: i18n("Failed to export to %1", String(exportFileDialog.selectedFile).substring('file://'.length))
                standardButtons: Kirigami.Dialog.Close
            }

            Kirigami.PromptDialog {
                id: exportedSuccessfullyPrompt
                title: i18n("Export Status")
                subtitle: i18n("Homescreen layout exported successfully to %1", String(exportFileDialog.selectedFile).substring('file://'.length))
                standardButtons: Kirigami.Dialog.Close
            }

            Kirigami.PromptDialog {
                id: confirmImportPrompt
                title: i18n("Confirm Import")
                subtitle: i18n("This will overwrite your existing homescreen layout!")
                standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
                onAccepted: Folio.FolioSettings.loadLayoutFromFile(importFileDialog.selectedFile);
            }
        }
    }
}
