// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.mobileinitialstart.initialstart

InitialStartModule {
    name: i18n("Complete!")
    contentItem: Item {
        id: root


        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.gridUnit

            Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                text: i18n("Your device is now ready. <br /><br />Enjoy <b>%1</b>!", InitialStartUtil.distroName)
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.fillHeight: true }

            Image {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                fillMode: Image.PreserveAspectFit
                source: "konqi-calling.png"
            }
        }
    }
}
