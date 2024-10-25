/*
 *   SPDX-FileCopyrightText: 2014 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.kirigami 2.20 as Kirigami

/**
 * Quick settings elements layout, change the height to clip.
 */
Item {
    id: root
    clip: true

    required property var actionDrawer
    required property int mode

    property QS.QuickSettingsModel quickSettingsModel

    enum Mode {
        Pages,
        ScrollView
    }

    readonly property real columns: Math.round(Math.min(6, Math.max(3, width / intendedColumnWidth)))
    readonly property real columnWidth: Math.floor(width / columns)
    readonly property int minimizedColumns: Math.round(Math.min(8, Math.max(5, width / intendedMinimizedColumnWidth)))
    readonly property real minimizedColumnWidth: Math.floor(width / minimizedColumns)

    readonly property real rowHeight: columnWidth * 0.7
    readonly property real fullHeight: fullView.implicitHeight

    readonly property real intendedColumnWidth: Kirigami.Units.gridUnit * 7
    readonly property real intendedMinimizedColumnWidth: Kirigami.Units.gridUnit * 4 + Kirigami.Units.smallSpacing
    readonly property real minimizedRowHeight: Kirigami.Units.gridUnit * 4 + Kirigami.Units.smallSpacing

    property real minimizedViewProgress: 0
    property real fullViewProgress: 1

    readonly property int columnCount: Math.floor(width/columnWidth)
    readonly property int rowCount: {
        let totalRows = Math.ceil(quickSettingsCount / columnCount);

        if (root.mode === QuickSettings.Pages) {
            // portrait orientation
            let maxRows = 5; // more than 5 is just disorienting
            let targetRows = Math.floor(Window.height * 0.65 / rowHeight);
            return Math.min(maxRows, Math.min(totalRows, targetRows));

        } else if (root.mode === QuickSettings.ScrollView) {
            // horizontal orientation
            let targetRows = Math.floor(Window.height * 0.8 / rowHeight);
            return Math.min(totalRows, targetRows);
        }
    }

    readonly property int pageSize: rowCount * columnCount
    readonly property int quickSettingsCount: quickSettingsModel.count

    function resetSwipeView() {
        if (root.mode === QuickSettings.Pages) {
            pageLoader.item.view.currentIndex = 0;
        }
    }

    // return to the first page when the action drawer is closed
    Connections {
        target: actionDrawer

        function onOpenedChanged() {
            if (!actionDrawer.opened) {
                resetSwipeView();
            }
        }
    }

    // view when fully open
    ColumnLayout {
        id: fullView
        opacity: root.fullViewProgress
        visible: opacity !== 0
        transform: Translate { y: (1 - fullView.opacity) * root.rowHeight }

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        // Dynamically loads the appropriate view
        Loader {
            id: pageLoader

            Layout.fillWidth: true
            Layout.minimumHeight: rowCount * rowHeight

            asynchronous: true
            sourceComponent: swipeViewComponent
        }

        BrightnessItem {
            Layout.bottomMargin: Kirigami.Units.smallSpacing * 2
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.fillWidth: true
        }
    }

    // view when in minimized mode
    RowLayout {
        id: minimizedView
        spacing: 0
        opacity: root.minimizedViewProgress
        visible: opacity !== 0
        transform: Translate { y: (1 - minimizedView.opacity) * -root.rowHeight }

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Repeater {
            model: QS.PaginateModel {
                sourceModel: quickSettingsModel
                pageSize: minimizedColumns
            }
            delegate: MobileShell.BaseItem {
                required property var modelData

                implicitHeight: root.minimizedRowHeight
                implicitWidth: root.minimizedColumnWidth
                horizontalPadding: (width - Kirigami.Units.gridUnit * 3) / 2
                verticalPadding: (height - Kirigami.Units.gridUnit * 3) / 2

                contentItem: QuickSettingsMinimizedDelegate {
                    restrictedPermissions: actionDrawer.restrictedPermissions

                    text: modelData.text
                    status: modelData.status
                    icon: modelData.icon
                    enabled: modelData.enabled
                    settingsCommand: modelData.settingsCommand
                    toggleFunction: modelData.toggle

                    onCloseRequested: {
                        actionDrawer.close();
                    }
                }
            }
        }
    }

    // Loads portrait and landscape quick settings view
    Component {
        id: swipeViewComponent

        ColumnLayout {
            readonly property var view: swipeView

            SwipeView {
                id: swipeView

                Layout.fillWidth: true
                Layout.preferredHeight: rowCount * rowHeight

                Repeater {
                    model: Math.ceil(quickSettingsCount / pageSize)
                    delegate: Flow {
                        id: flow
                        spacing: 0

                        required property int index

                        Repeater {
                            model: QS.PaginateModel {
                                sourceModel: quickSettingsModel
                                pageSize: root.pageSize
                                firstItem: pageSize * flow.index
                            }
                            delegate: Loader {
                                required property var modelData

                                asynchronous: true

                                sourceComponent: quickSettingComponent
                            }
                        }
                    }
                }
            }

            Loader {
                id: indicatorLoader

                Layout.alignment: Qt.AlignCenter
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing

                // Avoid wasting space when not loaded
                Layout.maximumHeight: active ? item.implicitHeight : 0

                active: swipeView.count > 1 ? true: false
                asynchronous: true

                sourceComponent: PageIndicator {
                    count: swipeView.count
                    currentIndex: swipeView.currentIndex

                    delegate: Rectangle {
                        implicitWidth: 8
                        implicitHeight: count > 1 ? 8 : 0

                        radius: parent.width / 2
                        color: Kirigami.Theme.disabledTextColor

                        opacity: index === currentIndex ? 0.95 : 0.45
                    }
                }
            }
        }
    }

    // Quick setting component
    Component {
        id: quickSettingComponent

        MobileShell.BaseItem {
            height: root.rowHeight
            width: root.columnWidth
            padding: Kirigami.Units.smallSpacing

            contentItem: QuickSettingsFullDelegate {
                restrictedPermissions: actionDrawer.restrictedPermissions

                text: modelData.text
                status: modelData.status
                icon: modelData.icon
                enabled: modelData.enabled
                settingsCommand: modelData.settingsCommand
                toggleFunction: modelData.toggle

                onCloseRequested: {
                    actionDrawer.close();
                }
            }
        }
    }
}
