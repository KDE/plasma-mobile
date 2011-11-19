/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the QtDeclarative module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions
** contained in the Technology Preview License Agreement accompanying
** this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights.  These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
**
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 1.0
import org.kde.qtextracomponents 0.1

Item {
    id: container

    property variant scrollArea
    property variant orientation: Qt.Vertical

    function position()
    {
        var ny = 0;
        if (container.orientation == Qt.Vertical)
            ny = scrollArea.visibleArea.yPosition * container.height;
        else
            ny = scrollArea.visibleArea.xPosition * container.width;
        if (ny > 2) return ny; else return 2;
    }

    function size()
    {
        var nh, ny;

        if (container.orientation == Qt.Vertical)
            nh = scrollArea.visibleArea.heightRatio * container.height;
        else
            nh = scrollArea.visibleArea.widthRatio * container.width;

        if (container.orientation == Qt.Vertical)
            ny = scrollArea.visibleArea.yPosition * container.height;
        else
            ny = scrollArea.visibleArea.xPosition * container.width;

        if (ny > 3) {
            var t;
            if (container.orientation == Qt.Vertical)
                t = Math.ceil(container.height - 3 - ny);
            else
                t = Math.ceil(container.width - 3 - ny);
            if (nh > t) return t; else return nh;
        } else return nh + ny;
    }

    Item {
        id: scrollPainter
        anchors.fill: parent
        opacity: 0
        Rectangle { anchors.fill: parent; color: "Black"; opacity: 0.5 }

        Rectangle {
            color: "white"
            radius: 2
            x: container.orientation == Qt.Vertical ? 2 : position()
            width: container.orientation == Qt.Vertical ? container.width - 4 : size()
            y: container.orientation == Qt.Vertical ? position() : 2
            height: container.orientation == Qt.Vertical ? size() : container.height - 4
        }
    }
    QIconItem {
        id: topButton
        anchors { top: parent.top; right: parent.left }
        icon: QIcon("go-top")
        width: 48
        height: width
        opacity: 0
        MouseArea {
            anchors.fill: parent
            onPressed: SequentialAnimation {
                PropertyAnimation { target: topButton; properties: "scale"; to: 0.8; duration: 50; }
                PropertyAnimation { target: topButton; properties: "scale"; to: 1; duration: 50; }
            }
            onClicked: ParallelAnimation{
                PropertyAnimation { target: topButton; properties: "opacity"; to: 0; duration: 200; }
                PropertyAnimation {
                    target: scrollArea; properties: "contentX,contentY";
                    to: 0; duration: 400; easing.type: Easing.InOutQuint;
                }
            }
        }
    }

    states: [
        State {
            name: "ScrollingUp"
            when: ((container.orientation == Qt.Vertical ? scrollArea.movingVertically : scrollArea.movingHorizontally) &&             scrollArea.verticalVelocity < -10 && scrollArea.contentY > header.height+2000)
            PropertyChanges { target: scrollPainter; opacity: 1.0 }
            PropertyChanges { target: topButton; opacity: 1.0 }
        },
        State {
            name: "Scrolling"
            when: ( (container.orientation == Qt.Vertical ? scrollArea.movingVertically : scrollArea.movingHorizontally))
            PropertyChanges { target: scrollPainter; opacity: 1.0 }
            PropertyChanges { target: topButton; opacity: 0.0 }
        }
    ]

    transitions: [
        Transition {
            to: "ScrollingUp"
            SequentialAnimation {
                PauseAnimation { duration: 400; }
                PropertyAnimation { target: topButton; properties: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
            }
        },
        Transition {
            to: "ScrollingUp"
            SequentialAnimation {
                PauseAnimation { duration: 400; }
                PropertyAnimation { target: topButton; properties: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
            }
        },
        Transition {
            from: "ScrollingUp"
            SequentialAnimation {
                PauseAnimation { duration: 1000; }
                PropertyAnimation { target: topButton; properties: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
            }
        },
        Transition {
            to: ""
            PropertyAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
        },
        Transition {
            from: ""; to: "Scrolling"
            PropertyAnimation { target: scrollPainter; properties: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
        }
    ]
}
