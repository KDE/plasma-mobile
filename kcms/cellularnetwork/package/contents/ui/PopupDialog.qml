/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.12 as Kirigami

Controls.Dialog {
    id: dialog
    
    anchors.centerIn: Controls.Overlay.overlay
    modal: true
    padding: Kirigami.Units.smallSpacing
    closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnReleaseOutside
    
    property int translateY: (1 - opacity) * Kirigami.Units.gridUnit * 2
    
    NumberAnimation on opacity {
        from: 0; to: 1;
        duration: Kirigami.Units.veryShortDuration
        easing.type: Easing.InOutQuad
        running: true
    }
    
    contentItem.transform: Translate { y: dialog.translateY }
    footer.transform: Translate { y: dialog.translateY }
    
    header: Item {
        transform: Translate { y: dialog.translateY }
        implicitHeight: heading.implicitHeight + Kirigami.Units.largeSpacing * 2

        Kirigami.Heading {
            id: heading
            level: 2
            text: dialog.title
            elide: Text.ElideRight
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.verticalCenter: parent.verticalCenter
            
            // use tooltip for long text that is elided
            Controls.ToolTip.visible: truncated && titleHoverHandler.hovered
            Controls.ToolTip.text: dialog.title
            HoverHandler {
                id: titleHoverHandler
            }
        }
    }
    
    background: Item {
        transform: Translate { y: dialog.translateY }
        
        RectangularGlow {
            anchors.fill: rect
            anchors.topMargin: 1
            cornerRadius: rect.radius * 2
            glowRadius: 2
            spread: 0.2
            color: Qt.rgba(0, 0, 0, 0.3)
        }
        Rectangle {
            id: rect
            anchors.fill: parent
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            color: Kirigami.Theme.backgroundColor
            radius: Kirigami.Units.smallSpacing
            
            Kirigami.Separator {
                id: topSeparator
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: dialog.header.implicitHeight
            }
            
            Kirigami.Separator {
                id: bottomSeparator
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dialog.footer.implicitHeight
            }
            
            Rectangle {
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                color: Kirigami.Theme.backgroundColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: topSeparator.bottom
                anchors.bottom: bottomSeparator.top
            }
        }
    }    
} 

