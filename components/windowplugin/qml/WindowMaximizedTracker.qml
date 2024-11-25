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

    property bool isCurrentWindowFullscreen: __internal.count > 0 && visibleWindowsModel.currentFullscreen && !WindowPlugin.WindowUtil.isShowingDesktop

    readonly property bool showingWindow: __internal.count > 0 && !WindowPlugin.WindowUtil.isShowingDesktop
    readonly property int windowCount: __internal.count

    property var __internal: KItemModels.KSortFilterProxyModel {
        id: visibleWindowsModel
        sourceModel: taskModel
        filterRowCallback: (sourceRow, sourceParent) => {
            const task = sourceModel.index(sourceRow, 0, sourceParent);
            let isFullScreen = sourceModel.data(task, TaskManager.AbstractTasksModel.IsFullScreen);
            let isMaximized = sourceModel.data(task, TaskManager.AbstractTasksModel.IsMaximized);
            if (sourceRow == 0) {
                visibleWindowsModel.currentFullscreen = isFullScreen;
            }
            return isFullScreen || isMaximized;
        }

        property bool currentFullscreen: false

        property var taskModel: TaskManager.TasksModel {
            id: tasksModel
            filterByVirtualDesktop: true
            filterByActivity: true
            filterMinimized: true
            filterByScreen: true
            filterHidden: true

            virtualDesktop: virtualDesktopInfo.currentDesktop
            activity: activityInfo.currentActivity

            sortMode: TaskManager.TasksModel.SortLastActivated

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
