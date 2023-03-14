/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.7
import org.kde.kirigami 2.4 as Kirigami


Item {
    id: root

    property alias model: spinnerView.model
    property alias currentIndex: spinnerView.currentIndex
    property alias delegate: spinnerView.delegate
    property alias moving: spinnerView.moving
    property int selectedIndex: -1
    property int fontSize: 14

    width: placeHolder.width*1.3
    height: placeHolder.height*3

    Text {
        id: placeHolder
        visible: false
        font.pointSize: root.fontSize
        text: "00"
    }

    PathView {
        id: spinnerView
        anchors.fill: parent
        model: 60
        clip: true
        pathItemCount: 5
        dragMargin: 800
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        delegate: Text {
            horizontalAlignment: Text.AlignHCenter
            width: spinnerView.width
            property int ownIndex: index
            text: index < 10 ? "0"+index : index
            color: Kirigami.Theme.textColor
            font.pointSize: root.fontSize
            opacity: PathView.itemOpacity
        }

        onMovingChanged: {
            userConfiguring = true
            if (!moving) {
                userConfiguringTimer.restart()
                selectedIndex = childAt(width/2, height/2).ownIndex
            }
        }

        path: Path {
            startX: spinnerView.width/2
            startY: spinnerView.height + 1.5*placeHolder.height
            PathAttribute { name: "itemOpacity"; value: 0 }
            PathLine {
                x: spinnerView.width/2
                y: spinnerView.height/2
            }
            PathAttribute { name: "itemOpacity"; value: 1 }
            PathLine {
                x: spinnerView.width/2
                y: -1.5*placeHolder.height
            }
            PathAttribute { name: "itemOpacity"; value: 0 }
        }
    }
}

