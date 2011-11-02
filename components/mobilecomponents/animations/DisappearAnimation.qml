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
import "Animations.js" as Animations

SequentialAnimation {
    id: disappearAnimation
    objectName: "disappearAnimation"

    property Item targetItem
    property int duration: Animations.normalDuration

    ScriptAction { script: targetItem.smooth = false; }

    ParallelAnimation {
        PropertyAnimation {
            properties: "opacity"
            duration: disappearAnimation.duration
            target: disappearAnimation.targetItem
            easing.type: Easing.OutExpo;
        }
        PropertyAnimation {
            properties: "scale"
            target: disappearAnimation.targetItem
            duration: disappearAnimation.duration * 0.6
            easing.type: Easing.OutExpo;
        }
    }
    ScriptAction { script: targetItem.smooth = true; }
}