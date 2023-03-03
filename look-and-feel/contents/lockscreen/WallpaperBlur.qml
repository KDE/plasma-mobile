/*
 * SPDX-FileCopyrightText: 2021-2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import Qt5Compat.GraphicalEffects

FastBlur {
    id: fastBlur
    cached: true
    radius: 50
    
    property bool blur
    opacity: blur ? 1 : 0
    
    Behavior on opacity {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.InOutQuad
        }
    }
}
