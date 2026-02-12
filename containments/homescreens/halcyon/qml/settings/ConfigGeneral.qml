// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as QQC2

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

Kirigami.ScrollablePage {
    id: page

    title: i18n("Homescreen Settings")

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    ColumnLayout {
        FormCard.FormHeader {
            title: i18n("Homescreen")
        }

        FormCard.FormCard {
            FormCard.FormComboBoxDelegate {
                id: wallpaperBlurCombobox
                text: i18n("Wallpaper blur effect")

                model: [
                    {"name": i18nc("Wallpaper blur effect", "None"), "value": 0},
                    {"name": i18nc("Wallpaper blur effect", "Simple"), "value": 1},
                    {"name": i18nc("Wallpaper blur effect", "Full"), "value": 2}
                ]

                textRole: "name"
                valueRole: "value"

                Component.onCompleted: {
                    currentIndex = indexOfValue(Plasmoid.settings.wallpaperBlurEffect);
                    dialog.parent = root;
                }
                onCurrentValueChanged: Plasmoid.settings.wallpaperBlurEffect = currentValue
            }

            FormCard.FormDelegateSeparator { above: wallpaperBlurCombobox; below: doubleTapToSleepSwitch }

            FormCard.FormSwitchDelegate {
                id: doubleTapToSleepSwitch
                text: i18n("Double tap to lock device")
                checked: Plasmoid.settings.doubleTapToLock
                onCheckedChanged: {
                    if (checked != Plasmoid.settings.doubleTapToLock) {
                        Plasmoid.settings.doubleTapToLock = checked;
                    }
                }
            }
        }
    }
}
