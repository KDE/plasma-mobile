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
    title: i18n('Icons')

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
        }
    }
}