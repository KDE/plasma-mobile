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
    property Folio.HomeScreen folio

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
                        Layout.preferredHeight: folio.HomeScreenState.pageCellHeight
                        Layout.fillWidth: true

                        AbstractDelegate {
                            folio: root.folio
                            anchors.centerIn: parent
                            implicitHeight: folio.HomeScreenState.pageCellHeight
                            implicitWidth: folio.HomeScreenState.pageCellWidth
                            name: i18n('Application')

                            contentItem: DelegateAppIcon {
                                height: root.folio.FolioSettings.delegateIconSize
                                width: root.folio.FolioSettings.delegateIconSize
                                source: 'applications-system'
                            }
                        }
                    }
                }

                FormCard.FormCard {
                    id: iconsCard
                    readonly property bool isVerticalOrientation: folio.HomeScreenState.pageOrientation === Folio.HomeScreenState.RegularPosition ||
                                                                folio.HomeScreenState.pageOrientation === Folio.HomeScreenState.RotateUpsideDown

                    readonly property string numOfRowsText: i18n("Number of rows")
                    readonly property string numOfColumnsText: i18n("Number of columns")

                    FormCard.FormSpinBoxDelegate {
                        id: iconSizeSpinBox
                        label: i18n("Size of icons on homescreen")
                        from: 16
                        to: 128
                        value: folio.FolioSettings.delegateIconSize
                        onValueChanged: {
                            if (value !== folio.FolioSettings.delegateIconSize) {
                                folio.FolioSettings.delegateIconSize = value;
                            }
                        }
                    }

                    FormCard.FormSpinBoxDelegate {
                        id: rowsSpinBox
                        label: iconsCard.isVerticalOrientation ? iconsCard.numOfRowsText : iconsCard.numOfColumnsText
                        from: 3
                        to: 10
                        value: folio.FolioSettings.homeScreenRows
                        onValueChanged: {
                            if (value !== folio.FolioSettings.homeScreenRows) {
                                folio.FolioSettings.homeScreenRows = value;
                            }
                        }
                    }

                    FormCard.FormSpinBoxDelegate {
                        id: columnsSpinBox
                        label: iconsCard.isVerticalOrientation ? iconsCard.numOfColumnsText : iconsCard.numOfRowsText
                        from: 3
                        to: 10
                        value: folio.FolioSettings.homeScreenColumns
                        onValueChanged: {
                            if (value !== folio.FolioSettings.homeScreenColumns) {
                                folio.FolioSettings.homeScreenColumns = value;
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
                        checked: folio.FolioSettings.showPagesAppLabels
                        onCheckedChanged: {
                            if (checked != folio.FolioSettings.showPagesAppLabels) {
                                folio.FolioSettings.showPagesAppLabels = checked;
                            }
                        }
                    }

                    FormCard.FormDelegateSeparator { above: showLabelsOnHomeScreen; below: showLabelsInFavourites }

                    FormCard.FormSwitchDelegate {
                        id: showLabelsInFavourites
                        text: i18n("Show labels in favorites bar")
                        checked: folio.FolioSettings.showFavouritesAppLabels
                        onCheckedChanged: {
                            if (checked != folio.FolioSettings.showFavouritesAppLabels) {
                                folio.FolioSettings.showFavouritesAppLabels = checked;
                            }
                        }
                    }

                    FormCard.FormDelegateSeparator { above: showLabelsInFavourites; below: pageTransitionCombobox }

                    FormCard.FormComboBoxDelegate {
                        id: pageTransitionCombobox
                        text: i18n("Page transition effect")

                        currentIndex: indexOfValue(folio.FolioSettings.pageTransitionEffect)
                        model: ListModel {
                            // we can't use i18n with ListElement
                            Component.onCompleted: {
                                append({"name": i18n("Slide"), "value": Folio.FolioSettings.SlideTransition});
                                append({"name": i18n("Cube"), "value": Folio.FolioSettings.CubeTransition});
                                append({"name": i18n("Fade"), "value": Folio.FolioSettings.FadeTransition});
                                append({"name": i18n("Stack"), "value": Folio.FolioSettings.StackTransition});
                                append({"name": i18n("Rotation"), "value": Folio.FolioSettings.RotationTransition});

                                // indexOfValue doesn't bind to model changes unfortunately, set currentIndex manually here
                                pageTransitionCombobox.currentIndex = pageTransitionCombobox.indexOfValue(folio.FolioSettings.pageTransitionEffect)
                            }
                        }

                        textRole: "name"
                        valueRole: "value"

                        onCurrentValueChanged: folio.FolioSettings.pageTransitionEffect = currentValue
                    }
                }

                FormCard.FormHeader {
                    title: i18n("Favorites Bar")
                }

                FormCard.FormCard {
                    FormCard.FormSwitchDelegate {
                        text: i18n('Show background')
                        checked: folio.FolioSettings.showFavouritesBarBackground
                        onCheckedChanged: {
                            if (checked !== folio.FolioSettings.showFavouritesBarBackground) {
                                folio.FolioSettings.showFavouritesBarBackground = checked;
                            }
                        }
                    }
                }

                FormCard.FormHeader {
                    title: i18nc("@title:group settings group", "Wallpaper")
                }

                FormCard.FormCard {
                    FormCard.FormSwitchDelegate {
                        id: showWallpaperBlur
                        text: i18nc("@option:check", "Show wallpaper blur effect")
                        checked: folio.FolioSettings.showWallpaperBlur
                        onCheckedChanged: {
                            if (checked != folio.FolioSettings.showWallpaperBlur) {
                                folio.FolioSettings.showWallpaperBlur = checked;
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
                        text: i18nc("@action:button", "Switch between homescreens and more wallpaper options")
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
                        let status = folio.FolioSettings.saveLayoutToFile(selectedFile);
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
                title: i18n("Import layout from")
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
                onAccepted: folio.FolioSettings.loadLayoutFromFile(importFileDialog.selectedFile);
            }
        }
    }
}
