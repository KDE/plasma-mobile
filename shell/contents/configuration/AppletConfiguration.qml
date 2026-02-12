// SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import org.kde.plasma.plasmoid
import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.configuration 2.0
import org.kde.kitemmodels 1.0 as KItemModels

import './private'

/**
 * This component is loaded by libplasma when the "configuration window" is requested for an applet.
 */
Item {
    id: root
    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

//BEGIN properties
    // Properties filled in or needed by libplasma

    property bool isContainment: false
    property alias app: appLoader.item
    property bool loadApp: true

    signal appLoaded()

//END properties

//BEGIN model

    property ConfigModel globalConfigModel: globalAppletConfigModel

    ConfigModel {
        id: globalAppletConfigModel
    }

    KItemModels.KSortFilterProxyModel {
        id: configDialogFilterModel
        sourceModel: configDialog.configModel
        filterRowCallback: (row, parent) => {
            return sourceModel.data(sourceModel.index(row, 0), ConfigModel.VisibleRole);
        }
    }

//END model

    function open(item) {
        if (item.source) {
            app.pageStack.push(Qt.resolvedUrl("private/ConfigurationAppletPage.qml"), {configItem: item, title: item.name});
        } else if (item.kcm) {
            app.pageStack.push(configurationKcmPageComponent, {kcm: item.kcm, internalPage: item.kcm.mainUi});
        }
    }

    Binding {
        // Window bindings
        root.Window.window.flags: Qt.FramelessWindowHint
        root.Window.window.visibility: Window.Maximized
    }

    Component {
        id: configurationKcmPageComponent
        ConfigurationKcmPage {}
    }

    Component {
        id: configListPageComponent
        ConfigListPage {
            onRequestOpen: (delegate) => root.open(delegate);
        }
    }

    Loader {
        id: appLoader
        anchors.fill: parent
        asynchronous: true
        active: root.loadApp

        // Load first page
        onLoaded: {
            // Push config list page
            app.pageStack.push(configListPageComponent, {
                title: i18nc("The title of the applet configuration window", "Configure %1", Plasmoid.metaData.name),
                model1: configDialogFilterModel,
                model2: root.globalConfigModel
            });

            root.appLoaded();
        }

        sourceComponent: Kirigami.ApplicationItem {
            id: app
            anchors.fill: parent

            pageStack {
                globalToolBar {
                    canContainHandles: true
                    style: Kirigami.ApplicationHeaderStyle.ToolBar
                    showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton
                }
                popHiddenPages: true
                columnView.columnResizeMode: Kirigami.ColumnView.SingleColumn
            }

            // Implement open/close animation
            Connections {
                target: root.Window.window

                function onVisibleChanged() {
                    if (visible) {
                        opacityAnim.to = 1;
                        opacityAnim.restart();
                    }
                }

                function onClosing(close) {
                    if (app.opacity !== 0) {
                        close.accepted = false;
                        opacityAnim.to = 0;
                        opacityAnim.restart();
                    }
                }
            }

            opacity: 0
            scale: 0.7 + 0.3 * app.opacity

            NumberAnimation on opacity {
                id: opacityAnim
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
                onFinished: {
                    if (app.opacity === 0) {
                        root.Window.window.close();
                    }
                }
            }
        }
    }
}

