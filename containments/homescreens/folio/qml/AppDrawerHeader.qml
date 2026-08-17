// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Effects

import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami

import org.kde.plasma.components 3.0 as PlasmaComponents
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio
import './delegate'

ColumnLayout {
    id: root
    property Folio.HomeScreen folio

    property alias currentCategoryIndex: tabBar.currentIndex
    property alias searchText: searchField.text

    property alias tabbar: tabBar

    readonly property real searchFieldMargin: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    function addSearchText(text: string) {
        searchField.text += text;
    }

    function clearSearchText(): void {
        searchField.text = '';
    }

    // Request to not focus on the search bar
    signal releaseFocusRequested()
    signal focusGridRequested()

    function focusSearchBar() {
        searchField.forceActiveFocus();
    }

    function focusTabBar() {
        tabBar.forceActiveFocus();
    }

    onActiveFocusChanged: {
        if (activeFocus && !searchField.activeFocus && !tabBar.activeFocus) {
            focusSearchBar();
        }
    }

    // Keyboard navigation
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            root.releaseFocusRequested();
            event.accepted = true;
        }
    }

    // Search field
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        Layout.margins: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing * 0.5
        Layout.alignment: Qt.AlignHCenter

        Kirigami.SearchField {
            id: searchField
            Layout.maximumWidth: Kirigami.Units.gridUnit * 26
            Layout.alignment: Qt.AlignHCenter

            background: Rectangle {
                radius: Kirigami.Units.cornerRadius
                color: Qt.rgba(255, 255, 255, (searchField.hovered || searchField.focus) ? 0.2 : 0.15)

                Behavior on color { ColorAnimation {} }
            }

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

            topPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
            bottomPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            horizontalAlignment: QQC2.TextField.AlignHCenter
            placeholderText: i18nc("@info:placeholder", "Search applications…")
            placeholderTextColor: Qt.rgba(255, 255, 255, 0.8)
            color: 'white'

            font.weight: Font.Bold

            Keys.onUpPressed: (event) => {
                folio.HomeScreenState.closeAppDrawer();
                event.accepted = true;
            }
            Keys.onBacktabPressed: (event) => {
                folio.HomeScreenState.closeAppDrawer();
                event.accepted = true;
            }

            Keys.onDownPressed: (event) => {
                root.focusTabBar();
                event.accepted = true;
            }
            Keys.onTabPressed: (event) => {
                root.focusTabBar();
                event.accepted = true;
            }

            Connections {
                target: folio.HomeScreenState
                function onViewStateChanged(): void {
                    if (folio.HomeScreenState.viewState !== Folio.HomeScreenState.AppDrawerView) {
                        // Reset search field if the app drawer is not shown
                        if (searchField.text !== '') {
                            searchField.text = '';
                        }
                    }
                }
            }
        }
    }

    PillTabBar {
        id: tabBar
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: Math.min(Kirigami.Units.gridUnit * 12, searchField.width)
        Layout.bottomMargin: Kirigami.Units.largeSpacing

        implicitHeight: Kirigami.Units.gridUnit * 1.75

        model: ["All Apps", "Categories"]

        onFocusUpRequested: root.focusSearchBar()
        onFocusDownRequested: root.focusGridRequested()
        onFocusNextRequested: root.focusGridRequested()
        onFocusPreviousRequested: root.focusSearchBar()

        onCurrentIndexChanged: {
            if (folio.HomeScreenState.swipeState !== Folio.HomeScreenState.SwipingAppDrawerCategories) {
                folio.HomeScreenState.goToAppDrawerPage(currentIndex, false);
            }
        }
    }

    Connections {
        target: folio.HomeScreenState

        function onAppDrawerPageNumChanged() {
            if (tabBar.currentIndex !== folio.HomeScreenState.currentAppDrawerPage) {
                tabBar.currentIndex = folio.HomeScreenState.currentAppDrawerPage;
            }
        }
    }
}
