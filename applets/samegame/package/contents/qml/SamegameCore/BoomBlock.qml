/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
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

import Qt 4.7
import Qt.labs.particles 1.0

Item {
    id: block
    property bool dying: false
    property bool spawned: false
    property int type: 0

    Behavior on x {
        enabled: spawned;
        SpringAnimation{ spring: 2; damping: 0.2 }
    }
    Behavior on y {
        SpringAnimation{ spring: 2; damping: 0.2 }
    }

    Image {
        id: img
        source: {
            if(type == 0){
                "pics/redStone.png";
            } else if(type == 1) {
                "pics/blueStone.png";
            } else {
                "pics/greenStone.png";
            }
        }
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        anchors.fill: parent
    }

    Particles {
        id: particles

        width: 1; height: 1
        anchors.centerIn: parent

        emissionRate: 0
        lifeSpan: 700; lifeSpanDeviation: 600
        angle: 0; angleDeviation: 360;
        velocity: 100; velocityDeviation: 30
        source: {
            if(type == 0){
                "pics/redStar.png";
            } else if (type == 1) {
                "pics/blueStar.png";
            } else {
                "pics/greenStar.png";
            }
        }
    }

    states: [
        State {
            name: "AliveState"; when: spawned == true && dying == false
            PropertyChanges { target: img; opacity: 1 }
        },

        State {
            name: "DeathState"; when: dying == true
            StateChangeScript { script: particles.burst(50); }
            PropertyChanges { target: img; opacity: 0 }
            StateChangeScript { script: block.destroy(1000); }
        }
    ]
}
