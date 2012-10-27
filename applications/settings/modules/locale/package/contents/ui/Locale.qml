/* Copyright (C) 2012 basysKom GmbH <info@basyskom.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1

Item {
    id: localeModule
    objectName: "localeModule"

    LocaleSettings {
        id: localeSettings
    }

    width: 800; height: 500

    MobileComponents.Package {
        id: localePackage
        name: "org.kde.active.settings.locale"
    }

    Column {
        id: titleCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        PlasmaExtras.Title {
            text: settingsComponent.name
            opacity: 1
        }
        PlasmaComponents.Label {
            id: descriptionLabel
            text: settingsComponent.description
            opacity: .4
        }
    }

    Grid {
        id: formLayout
        columns: 2
        rows: 4
        spacing: theme.defaultFont.mSize.height
        anchors {
            top: titleCol.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: theme.defaultFont.mSize.height
        }

        PlasmaComponents.Label {
            id: languageLabel
            text: i18n("Language:")
            anchors {
                right: languageButton.left
                rightMargin: theme.defaultFont.mSize.width
            }
        }

        PlasmaComponents.Button {
            id: languageButton
            text: localeSettings.language
            onClicked: languagePickerDialog.open()
        }
    }

    PlasmaComponents.CommonDialog {
        id: languagePickerDialog
        titleText: i18n("Select a Language")
        buttonTexts: [i18n("Cancel")]
        onButtonClicked: close()
        content: Loader {
            id: languagePickerLoader
            width: theme.defaultFont.mSize.width*22
            height: theme.defaultFont.mSize.height*25
        }
        onStatusChanged: {
            if (status == PlasmaComponents.DialogStatus.Open) {
                languagePickerLoader.source = "LanguagePicker.qml"
                languagePickerLoader.item.focusTextInput()
            }
        }
    }

    Component.onCompleted: {
        print("Loaded Locale.qml successfully.");
    }
}
