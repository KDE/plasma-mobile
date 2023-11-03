/*
    SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.11 as QQC2

import org.kde.kcmutils as KCM
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
            sortRoleName: "name"
            sortOrder: Qt.AscendingOrder
        }

        delegate: QQC2.CheckDelegate {
            width: ListView.view.width
            text: model.name
            checked: model.enabled
            onToggled: {
                model.enabled = checked
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
