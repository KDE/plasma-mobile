// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as Controls

import org.kde.kirigami 2.12 as Kirigami

import cellularnetworkkcm 1.0

ColumnLayout {
    id: root
    
    property var model
    property alias count: repeater.count
    
    spacing: 0
    visible: count > 0
    
    Repeater {
        id: repeater
        model: root.model
        
        delegate: Kirigami.InlineMessage {
            Layout.bottomMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            visible: true
            text: modelData.message
            type: {
                switch (modelData.type) {
                    case InlineMessage.Information: return Kirigami.MessageType.Information;
                    case InlineMessage.Positive: return Kirigami.MessageType.Positive;
                    case InlineMessage.Warning: return Kirigami.MessageType.Warning;
                    case InlineMessage.Error: return Kirigami.MessageType.Error;
                }
                return Kirigami.MessageType.Error; 
            }
            
            actions: [
                Kirigami.Action {
                    icon.name: "dialog-close"
                    onTriggered: kcm.removeMessage(model.index)
                }
            ]
        }
    }
}
