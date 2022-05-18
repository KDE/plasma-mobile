/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0


LauncherContainer {
    id: root

    readonly property int count: flow.width / cellWidth

    flow.flow: Flow.TopToBottom

    height: visible ? cellHeight : 0

    frame.implicitWidth: cellWidth * Math.max(1, flow.children.length) + frame.leftPadding + frame.rightPadding

    Behavior on height {
        NumberAnimation {
            duration: PlasmaCore.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on opacity {
        OpacityAnimator {
            duration: PlasmaCore.Units.longDuration * 4
            easing.type: Easing.InOutQuad
        }
    }
}
