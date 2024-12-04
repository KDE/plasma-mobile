// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami

OpacityMask {
    id: root

    property var flickable

    source: flickable
    maskSource: Rectangle {
        id: mask
        width: flickable.width
        height: flickable.height

        property real gradientPct: (Kirigami.Units.gridUnit * 2) / flickable.height

        gradient: Gradient {
            GradientStop { position: 0.0; color: flickable.atYBeginning ? 'white' : 'transparent' }
            GradientStop { position: mask.gradientPct; color: 'white' }
            GradientStop { position: 1.0 - mask.gradientPct; color: 'white' }
            GradientStop { position: 1.0; color: flickable.atYEnd ? 'white' : 'transparent' }
        }
    }
}
