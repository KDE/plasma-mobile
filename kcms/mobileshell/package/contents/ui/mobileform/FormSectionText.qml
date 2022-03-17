/*
 * Copyright 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami

Label {
    color: Kirigami.Theme.disabledTextColor
    wrapMode: Label.Wrap
    
    Layout.maximumWidth: Kirigami.Units.gridUnit * 30
    Layout.alignment: Qt.AlignHCenter
    Layout.leftMargin: Kirigami.Units.gridUnit
    Layout.rightMargin: Kirigami.Units.gridUnit
    Layout.bottomMargin: Kirigami.Units.largeSpacing
    Layout.topMargin: Kirigami.Units.largeSpacing
    Layout.fillWidth: true
}
