/*
 * SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtGraphicalEffects 1.12

FastBlur {
    id: fastBlur
    cached: true
    radius: 50
    opacity: 0
    
    property bool blur
    
    Behavior on blur {
        NumberAnimation {
            target: fastBlur
            property: "opacity"
            duration: 1000
            to: fastBlur.blur ? 0 : 1
            easing.type: Easing.InOutQuad
        }
    }
}
