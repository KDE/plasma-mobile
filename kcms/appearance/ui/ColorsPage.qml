// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.newstuff as NewStuff

FormCard.FormCardPage {
    id: root
    title: i18n('Colors')

    topPadding: Kirigami.Units.gridUnit
    bottomPadding: Kirigami.Units.gridUnit
    leftPadding: 0
    rightPadding: 0

    ColumnLayout {

        FormCard.FormCard {
            FormCard.FormSwitchDelegate {
                id: darkThemeSwitch
                visible: !customThemeSwitch.checked
                text: i18n('Dark Theme')
                onClicked: {

                } 
            }

            FormCard.FormSwitchDelegate {
                id: customThemeSwitch
                text: i18n('Custom color scheme')
                onClicked: {

                }
            }

            FormCard.FormButtonDelegate {
                id: selectColorScheme
                visible: customThemeSwitch.checked
                text: i18n('Select color scheme')
            }
        }

        FormCard.FormHeader {
            title: i18n('Accent Color')
        }

        FormCard.FormCard {
            FormCard.FormComboBoxDelegate {
                id: accentColorComboBox
                text: i18n('Get accent color from…')

                readonly property string colorSchemeString: i18n('Color Scheme')
                readonly property string wallpaperString: i18n('Wallpaper')
                readonly property string customSelectionString: i18n('Custom Selection')

                currentIndex: 0 // indexOfValue(ShellSettings.Settings.actionDrawerTopLeftMode)
                model: ListModel {
                    // we can't use i18n with ListElement
                    Component.onCompleted: {
                        append({"name": accentColorComboBox.colorSchemeString, "value": 0});
                        append({"name": accentColorComboBox.wallpaperString, "value": 1});
                        append({"name": accentColorComboBox.customSelectionString, "value": 2});

                        // indexOfValue doesn't bind to model changes unfortunately, set currentIndex manually here
                        accentColorComboBox.currentIndex = accentColorComboBox.indexOfValue(ShellSettings.Settings.actionDrawerTopLeftMode)
                    }
                }

                textRole: "name"
                valueRole: "value"

                Component.onCompleted: dialog.parent = root
                // onCurrentValueChanged: ShellSettings.Settings.actionDrawerTopLeftMode = currentValue
            }
        }
    }
}