/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.plasmoid 2.0
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

Item {
    id: root

    readonly property int reservedSpaceForLabel: metrics.height
    readonly property int cellWidth: root.width / Math.floor(root.width / ((availableCellHeight - reservedSpaceForLabel) + Kirigami.Units.smallSpacing*4))
    readonly property int cellHeight: availableCellHeight
    property int availableCellHeight: Kirigami.Units.iconSizes.huge + reservedSpaceForLabel

    property ContainmentLayoutManager.AppletsLayout appletsLayout

    property alias frame: frame
    property alias flow: applicationsFlow

    implicitWidth: frame.implicitWidth
    implicitHeight: Math.max(Kirigami.Units.gridUnit*3, frame.implicitHeight)

    Controls.Label {
        id: metrics
        text: "M\nM"
        visible: false
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
    }

    Item {
        id: spacer
        width: Kirigami.Units.gridUnit * 4
        height: width
    }

    Controls.Control {
        id: frame
        anchors.centerIn: parent
        implicitWidth: contentItem.implicitWidth
        implicitHeight: contentItem.implicitHeight
        height: parent.height

        leftPadding: 0
        topPadding: 0
        rightPadding: 0
        bottomPadding: 0

        // With a mousearea, it will be possible to drag with touch also on empty places
        contentItem: MouseArea {
            implicitWidth: applicationsFlow.implicitWidth
            implicitHeight: applicationsFlow.implicitHeight
            Flow {
                id: applicationsFlow

                spacing: 0
                anchors.fill: parent

                move: Transition {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                        properties: "x,y"
                    }
                }
            }
        }
        Behavior on implicitWidth {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}
