// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0

ParallelAnimation {
    id: disappearAnimation
    objectName: "disappearAnimation"
    property Item targetItem
    //property alias target: appearAnimation.targetItem
    property int duration: 250*2
    /*

    PropertyAnimation {
        target: disappearAnimation.targetItem
        properties: "opacity"
        from: 0; to: 1.0
        duration: disappearAnimation.duration;
        easing.type: Easing.InExpo;
    }
    PropertyAnimation {
        target: disappearAnimation.targetItem
        properties: "scale"
        from: 1.0; to: 0.8
        duration: disappearAnimation.duration;
        easing.type: Easing.InExpo;
    }
    */
    PropertyAnimation {
        properties: "opacity"
        duration: disappearAnimation.duration
        target: disappearAnimation.targetItem
        //duration: 175;
        easing.type: Easing.OutExpo;
    }
    PropertyAnimation {
        properties: "scale"
        target: disappearAnimation.targetItem
        duration: disappearAnimation.duration * 0.6
        easing.type: Easing.OutExpo;
    }
}
