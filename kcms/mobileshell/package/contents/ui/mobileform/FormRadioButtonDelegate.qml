/*
 * Copyright 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami

AbstractFormDelegate {
    id: root
    
    property string text: ""
    property alias checked: radioButtonItem.checked
    property alias radioButton: radioButtonItem
    
    onClicked: checked = true;
    
    Layout.fillWidth: true
    
    contentItem: RowLayout {
        RadioButton {
            id: radioButtonItem
            Layout.rightMargin: Kirigami.Units.largeSpacing
        }
        
        Label {
            text: root.text
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
}


