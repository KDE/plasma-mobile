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

Rectangle {
    id: root
    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    color: "transparent"

//BEGIN properties

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

//BEGIN functions

    function saveConfig() {
        if (app.pageStack.currentItem.saveConfig) {
            app.pageStack.currentItem.saveConfig()
        }
        for (var key in Plasmoid.configuration) {
            if (app.pageStack.currentItem["cfg_"+key] !== undefined) {
                Plasmoid.configuration[key] = app.pageStack.currentItem["cfg_"+key]
            }
        }
    }

    function configurationHasChanged() {
        for (var key in Plasmoid.configuration) {
            if (app.pageStack.currentItem["cfg_"+key] !== undefined) {
                //for objects == doesn't work
                if (typeof Plasmoid.configuration[key] == 'object') {
                    for (var i in Plasmoid.configuration[key]) {
                        if (Plasmoid.configuration[key][i] != app.pageStack.currentItem["cfg_"+key][i]) {
                            return true;
                        }
                    }
                    return false;
                } else if (app.pageStack.currentItem["cfg_"+key] != Plasmoid.configuration[key]) {
                    return true;
                }
            }
        }
        return false;
    }


    function settingValueChanged() {
        if (app.pageStack.currentItem.saveConfig !== undefined) {
            app.pageStack.currentItem.saveConfig();
        } else {
            root.saveConfig();
        }
    }

    function pushReplace(item, config) {
        let page;
        if (app.pageStack.depth === 0) {
            page = app.pageStack.push(item, config);
        } else {
            page = app.pageStack.replace(item, config);
        }
        app.currentConfigPage = page;
    }

    function open(item) {
        app.isAboutPage = false;
        if (item.source) {
            app.isAboutPage = item.source === "AboutPlugin.qml";
            pushReplace(Qt.resolvedUrl("ConfigurationAppletPage.qml"), {configItem: item, title: item.name});
        } else if (item.kcm) {
            pushReplace(configurationKcmPageComponent, {kcm: item.kcm, internalPage: item.kcm.mainUi});
        } else {
            app.pageStack.pop();
        }
    }

//END functions


//BEGIN connections

    Connections {
        target: root.Window.window
        function onVisibleChanged() {
            if (root.Window.window.visible) {
                root.Window.window.showMaximized();
            }
        }
    }

//END connections

//BEGIN UI components

    Component {
        id: configurationKcmPageComponent
        ConfigurationKcmPage {}
    }

    Loader {
        id: appLoader
        anchors.fill: parent
        asynchronous: true
        active: root.loadApp
        onLoaded: {
            // if we are a containment then the first item will be ConfigurationContainmentAppearance
            // if the applet does not have own configs then the first item will be Shortcuts
            if (isContainment || !configDialog.configModel || configDialog.configModel.count === 0) {
                root.open(root.globalConfigModel.get(0))
            } else {
                root.open(configDialog.configModel.get(0))
            }

            root.appLoaded();
        }

        sourceComponent: Kirigami.ApplicationItem {
            id: app
            anchors.fill: parent

            // animation on show
            opacity: 0
            NumberAnimation on opacity {
                to: 1
                running: true
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }

            pageStack.globalToolBar.canContainHandles: true
            pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
            pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;

            property var currentConfigPage: null
            property bool isAboutPage: false

            // pop pages when not in use
            Connections {
                target: app.pageStack
                function onCurrentIndexChanged() {
                    // wait for animation to finish before popping pages
                    timer.restart();
                }
            }

            Timer {
                id: timer
                interval: 300
                onTriggered: {
                    let currentIndex = app.pageStack.currentIndex;
                    while (app.pageStack.depth > (currentIndex + 1) && currentIndex >= 0) {
                        app.pageStack.pop();
                    }
                }
            }

            footer: Kirigami.NavigationTabBar {
                id: footerBar
                visible: count > 1
                height: visible ? implicitHeight : 0
                Repeater {
                    model: root.isContainment ? globalConfigModel : undefined
                    delegate: configCategoryDelegate
                }
                Repeater {
                    model: configDialogFilterModel
                    delegate: configCategoryDelegate
                }
                Repeater {
                    model: !root.isContainment ? globalConfigModel : undefined
                    delegate: configCategoryDelegate
                }
            }

            Component {
                id: configCategoryDelegate
                Kirigami.NavigationTabButton {
                    icon.name: model.icon
                    text: model.name
                    width: footerBar.buttonWidth
                    QQC2.ButtonGroup.group: footerBar.tabGroup

                    onClicked: {
                        if (checked) {
                            root.open(model);
                        }
                    }

                    checked: {
                        if (app.pageStack.currentItem) {
                            if (model.kcm && app.pageStack.currentItem.kcm) {
                                return model.kcm == app.pageStack.currentItem.kcm;
                            } else if (app.pageStack.currentItem.configItem) {
                                return model.source == app.pageStack.currentItem.configItem.source;
                            } else {
                                return app.pageStack.currentItem.source == Qt.resolvedUrl(model.source);
                            }
                        }
                        return false;
                    }
                }
            }
        }
    }
//END UI components
}

