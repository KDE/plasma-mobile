// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15

/**
 * Serves a similar function as a QQC2.Control, but does not
 * take touch input events, preventing conflicts with Flickable.
 */

Item {
    id: root

    property real topInset: 0
    property real bottomInset: 0
    property real leftInset: 0
    property real rightInset: 0

    property real padding: 0
    property real verticalPadding: padding
    property real horizontalPadding: padding
    property real topPadding: verticalPadding
    property real bottomPadding: verticalPadding
    property real leftPadding: horizontalPadding
    property real rightPadding: horizontalPadding

    property Item contentItem: Item {}
    property Item background: Item {}

    implicitHeight: topPadding + bottomPadding + contentItem.implicitHeight
    implicitWidth: leftPadding + rightPadding + contentItem.implicitWidth

    onContentItemChanged: {
        if (contentItem !== null && contentItem !== undefined) {
            contentItem.parent = contentItemLoader;
            contentItem.anchors.fill = contentItemLoader;
        }
    }

    onBackgroundChanged: {
        if (background !== null && background !== undefined) {
            background.parent = backgroundLoader;
            background.anchors.fill = backgroundLoader;
        }
    }

    Item {
        id: backgroundLoader
        anchors.fill: parent
        anchors.leftMargin: root.leftInset
        anchors.rightMargin: root.rightInset
        anchors.topMargin: root.topInset
        anchors.bottomMargin: root.bottomInset
    }

    Item {
        id: contentItemLoader
        anchors.fill: parent
        anchors.leftMargin: root.leftPadding
        anchors.rightMargin: root.rightPadding
        anchors.topMargin: root.topPadding
        anchors.bottomMargin: root.bottomPadding
    }
}

