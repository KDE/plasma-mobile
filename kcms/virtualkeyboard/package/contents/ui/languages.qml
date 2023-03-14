/*
    SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.11 as QQC2

import org.kde.kirigami 2.10 as Kirigami
import org.kde.kcm 1.3 as KCM
import org.kde.kitemmodels 1.0 as KItemModel

import org.kde.kcm.virtualkeyboard 1.0

KCM.ScrollViewKCM {
    id: root

    title: i18n("Languages")

    view: ListView {
        id: languageList

        clip: true

        model: KItemModel.KSortFilterProxyModel {
            sourceModel: kcm.languageModel
            sortRole: "name"
            sortOrder: Qt.Ascending
        }

        delegate: Kirigami.AbstractListItem {
            QQC2.CheckBox {
                text: model.name
                checked: model.enabled
                onCheckedChanged: {
                    model.enabled = checked
                }
            }
        }
    }

    footer: RowLayout {
        QQC2.Button {
            text: i18n("Apply")
            icon.name: "dialog-ok"
            onClicked: kcm.pop()
            Layout.alignment: Qt.AlignRight
        }
    }
}
