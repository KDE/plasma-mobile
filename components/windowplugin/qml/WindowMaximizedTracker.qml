// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TaskManager
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin
import org.kde.kitemmodels as KItemModels

// Helper component that uses Plasma's tasks model to provide whether a maximized window is showing on the current screen.
QtObject {
    // Setting this property is necessary to filter by screen, otherwise the model will use all screens.
    // Set it to Plasmoid.containment.screenGeometry in a plasmoid to accomplish this.
    property alias screenGeometry: tasksModel.screenGeometry

    readonly property bool showingWindow: __internal.count > 0 && !WindowPlugin.WindowUtil.isShowingDesktop
    readonly property int windowCount: __internal.count

    property var __internal: KItemModels.KSortFilterProxyModel {
        id: visibleMaximizedWindowsModel
        filterRoleName: 'IsMinimized'
        filterString: 'false'
        sourceModel: TaskManager.TasksModel {
            id: tasksModel
            filterByVirtualDesktop: true
            filterByActivity: true
            filterNotMaximized: true
            filterByScreen: true
            filterHidden: true

            virtualDesktop: virtualDesktopInfo.currentDesktop
            activity: activityInfo.currentActivity

            groupMode: TaskManager.TasksModel.GroupDisabled
        }

        property var vdi: TaskManager.VirtualDesktopInfo {
            id: virtualDesktopInfo
        }

        property var ai: TaskManager.ActivityInfo {
            id: activityInfo
        }
    }
}
