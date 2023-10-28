// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2023 Alexey Andreyev <aa13q@ya.ru>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.kwin

import org.kde.plasma.private.mobileshell as MobileShell

SceneEffect {
    id: effect

    delegate: TaskSwitcher {}
    
    property real partialActivationFactor: 0
    property bool gestureInProgress: false
    
    property int _animationDuration: Kirigami.Units.veryLongDuration
    
    StateGroup {
        id: statusGroup
        state: "inactive"
        states: [
            State {
                name: "inactive"
            },
            State {
                name: "activating"
            },
            State {
                name: "deactivating"
            },
            State {
                name: "active"
            }
        ]
    }
    
    // MobileShell.ShellUtil.setIsTaskSwitcherVisible(false)
}
