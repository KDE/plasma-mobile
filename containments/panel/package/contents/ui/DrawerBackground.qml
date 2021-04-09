/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4 as QQC2
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.12 as Kirigami

QQC2.Control {
    id: root
    
    required property color backgroundColor 
    
    leftPadding: units.largeSpacing
    topPadding: units.largeSpacing
    rightPadding: units.largeSpacing
    bottomPadding: units.largeSpacing

    background: Item {
        MouseArea {
            anchors.fill: parent
        }
        PlasmaCore.FrameSvgItem {
            imagePath: "widgets/panel-background"
            prefix: "shadow"
            anchors.fill: container
            anchors.margins: -PlasmaCore.Units.smallSpacing
        }
        Rectangle {
            id: container
            color: backgroundColor
            anchors {
                fill: parent
                leftMargin: PlasmaCore.Units.smallSpacing
                rightMargin: PlasmaCore.Units.smallSpacing
                topMargin: PlasmaCore.Units.smallSpacing
                bottomMargin: PlasmaCore.Units.smallSpacing
            }
            radius: PlasmaCore.Units.smallSpacing
        }
    }
}
