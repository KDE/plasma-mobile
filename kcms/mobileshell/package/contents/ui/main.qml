/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kcm 1.3 as KCM

KCM.SimpleKCM {
    id: root

    title: i18n("Shell")

    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    
    Kirigami.FormLayout {
        id: form
        wideMode: false
        
        Item {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Navigation Panel")
            Kirigami.FormData.isSection: true
        }
        
        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Remove panel (only use gestures):")
            Layout.maximumWidth: form.width
            text: checked ? i18n("On") : i18n("Off")
            checked: !kcm.navigationPanelEnabled
            onCheckStateChanged: {
                if (checked != !kcm.navigationPanelEnabled) {
                    kcm.navigationPanelEnabled = !checked;
                }
            }
        }
    }
}
