// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

GridView {
    maximumFlickVelocity: 5000

    highlightFollowsCurrentItem: true
    highlight: highlightComponent

    onActiveFocusChanged: {
        if (!activeFocus) {
            currentIndex = -1;
        }
    }

    onDraggingChanged: {
        if (dragging) {
            currentIndex = -1;
        }
    }

    Component {
        id: highlightComponent
        Rectangle {
            color: Kirigami.ColorUtils.tintWithAlpha(PlasmaCore.ColorScope.highlightColor, PlasmaCore.ColorScope.backgroundColor, 0.6)
            radius: PlasmaCore.Units.smallSpacing

            Behavior on x { SpringAnimation { spring: 3; damping: 0.2 } }
            Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }
        }
    }
}
