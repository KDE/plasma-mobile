
import QtQuick
import org.kde.taskmanager as TaskManager

QtObject {
    id: tasksHelper

    // desktop filename of the app which we want to fullscreen temporarily
    property string appId: "inspection.desktop"
    property bool initiallyFullScreen: false // FIXME

    property var tasksModel: TaskManager.TasksModel {
        id: tasksModel
        filterByVirtualDesktop: false
        filterByActivity: false
        filterMinimized: false
        filterByScreen: false
        filterHidden: false

        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity

        sortMode: TaskManager.TasksModel.SortLastActivated

        groupMode: TaskManager.TasksModel.GroupDisabled
        Component.onCompleted: {
            console.log("tasksModel complete")
        }

    }

    property var vdi: TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    property var ai: TaskManager.ActivityInfo {
        id: activityInfo
    }

    /* Find the modelindex for our appId */
    function __getAppIndex() {
        let len = tasksModel.count;
        for (let i = 0; i < tasksModel.count; i++) {
            const task = tasksModel.index(i, 0);
            let appId = tasksModel.data(task, TaskManager.AbstractTasksModel.AppId);
            console.log(" ... appId: " + appId);
            if (appId === tasksHelper.appId) {
                return task;
            }
        }
        return null;
    }

    function setAppFullScreen() {
        let appIndex = __getAppIndex();
        if (appIndex === null) {
            console.log("Didn't find a matching window to make fullscreen")
            return;
        }
        let isFullScreen = tasksModel.data(appIndex, TaskManager.AbstractTasksModel.IsFullScreen);
        tasksHelper.initiallyFullScreen = isFullScreen;
        console.log("Was fullscreen? " + initiallyFullScreen);
        if (!isFullScreen) {
            tasksModel.requestToggleFullScreen(appIndex);
        }
    }

    function restoreApp() {
        let appIndex = __getAppIndex();
        if (appIndex === null) {
            console.log("Didn't find a matching window to restore")
            return;
        }
        let isFullScreen = tasksModel.data(appIndex, TaskManager.AbstractTasksModel.IsFullScreen);
        console.log("is fullscreen? " + isFullScreen + " was fullscreen? " + tasksHelper.initiallyFullScreen);
        //if (isFullScreen && !tasksHelper.initiallyFullScreen) {
        if (isFullScreen) {
                tasksModel.requestToggleFullScreen(appIndex);
        }
    }
}
