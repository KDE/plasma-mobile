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
    property string description: ""
    property alias checked: switchItem.checked
    property alias switchControl: switchItem
    
    onClicked: checked = !checked;
    
    Layout.fillWidth: true
    
    contentItem: RowLayout {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            Label {
                Layout.fillWidth: true
                text: root.text
                elide: Text.ElideRight
            }
            
            Label {
                visible: root.description !== ""
                Layout.fillWidth: true
                text: root.description
                color: Kirigami.Theme.disabledTextColor
                font: Kirigami.Theme.smallFont
                elide: Text.ElideRight
            }
        }
        
        Switch {
            id: switchItem
            Layout.leftMargin: Kirigami.Units.largeSpacing
        }
    }
}
