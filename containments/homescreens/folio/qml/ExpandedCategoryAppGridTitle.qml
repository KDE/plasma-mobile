/*
    SPDX-FileCopyrightText: 2026 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Item {
    id: categoryLabelAnchor
    z: 9999 // ensures the label floats above all everything

    property var categoryAppGrid

    // base coordinates within the grid's content space
    readonly property real startX: categoryAppGrid.__originX + categoryAppGrid.contentX
    readonly property real startY: categoryAppGrid.__originY + categoryAppGrid.contentY + Kirigami.Units.gridUnit * 3

    readonly property real endX: (categoryAppGrid.width * 0.5) + categoryAppGrid.contentX
    readonly property real endY: Kirigami.Units.gridUnit * 3

    // linear interpolation based on animation progress
    readonly property real lerpX: startX + (endX - startX) * categoryAppGrid.animationProgress
    readonly property real lerpY: startY + (endY - startY) * categoryAppGrid.animationProgress

    // final position that translate from content coordinates to view coordinates
    x: lerpX - categoryAppGrid.contentX + categoryAppGrid.originX
    y: Math.max(lerpY - categoryAppGrid.contentY + categoryAppGrid.originY, Kirigami.Units.gridUnit * 3)

    scale: 0.5 + (0.5 * categoryAppGrid.animationProgress)
    opacity: categoryAppGrid.animationProgress
    visible: opacity > 0 && categoryAppGrid.__category !== ""

    QQC2.Label {
        id: categoryLabel
        anchors.centerIn: parent

        width: categoryAppGrid.width - (Kirigami.Units.largeSpacing * 2)

        text: categoryAppGrid.__category
        color: "white"
        style: Text.Normal
        styleColor: "transparent"
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.MarkdownText

        elide: Text.ElideRight
        wrapMode: Text.Wrap
        maximumLineCount: 2

        font.weight: Font.Bold
        font.pointSize: 18
    }
}
