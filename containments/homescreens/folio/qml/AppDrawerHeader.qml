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
        tabListView.forceActiveFocus();
    }

    onActiveFocusChanged: {
        if (activeFocus && !searchField.activeFocus && !tabListView.activeFocus) {
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
        Layout.bottomMargin: 0
        Layout.alignment: Qt.AlignHCenter

        Kirigami.SearchField {
            id: searchField
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            Layout.alignment: Qt.AlignHCenter

            background: Rectangle {
                radius: Kirigami.Units.cornerRadius
                color: Qt.rgba(255, 255, 255, (searchField.hovered || searchField.focus) ? 0.2 : 0.1)

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

    // Tabbar
    Item {
        id: tabBar
        Layout.fillWidth: true
        Layout.bottomMargin: -Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing * 2
        Layout.leftMargin: -Kirigami.Units.smallSpacing
        Layout.rightMargin: -Kirigami.Units.smallSpacing

        implicitHeight: Kirigami.Units.gridUnit * 2
        Layout.minimumHeight: implicitHeight

        property int currentIndex: 0
        onCurrentIndexChanged: {
            if (tabListView.currentIndex !== currentIndex) {
                tabListView.currentIndex = currentIndex;
            }
        }

        ListView {
            id: tabListView

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            model: folio.ApplicationListModel.categories
            currentIndex: tabBar.currentIndex
            onCurrentIndexChanged: {
                if (tabBar.currentIndex !== currentIndex) {
                    tabBar.currentIndex = currentIndex;
                }
            }

            readonly property real defaultMargin: Kirigami.Units.gridUnit + Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
            readonly property real moveDuration: Kirigami.Units.longDuration

            width: Math.min(contentWidth, tabBar.width)
            leftMargin: defaultMargin
            rightMargin: defaultMargin

            spacing: Kirigami.Units.smallSpacing
            orientation: ListView.Horizontal
            flickableDirection: Flickable.AutoFlickIfNeeded

            property int dynamicMoveDuration: tabListView.moveDuration
            highlightMoveDuration: dynamicMoveDuration
            highlightResizeDuration: 0
            highlightFollowsCurrentItem: true

            preferredHighlightBegin: tabListView.defaultMargin
            preferredHighlightEnd: Math.max(preferredHighlightBegin, tabBar.width - tabListView.defaultMargin)

            highlightRangeMode: ListView.ApplyRange

            snapMode: ListView.SnapToItem

            Keys.onUpPressed: (event) => {
                root.focusSearchBar();
                event.accepted = true;
            }
            Keys.onDownPressed: (event) => {
                root.focusGridRequested();
                event.accepted = true;
            }
            Keys.onTabPressed: (event) => {
                root.focusGridRequested();
                event.accepted = true;
            }
            Keys.onBacktabPressed: (event) => {
                root.focusSearchBar();
                event.accepted = true;
            }

            keyNavigationEnabled: true
            keyNavigationWraps: true

            delegate: Item {
                id: tabButton
                readonly property bool checked: tabListView.currentIndex === index

                width: txtMeter.advanceWidth + Math.round(Kirigami.Units.gridUnit * 1.75)
                height: tabListView.height

                TextMetrics {
                    id: txtMeter
                    font: label.font
                    text: modelData
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: Kirigami.Units.smallSpacing
                    anchors.bottomMargin: Kirigami.Units.smallSpacing
                    property color buttonColor: "white"

                    color: tabButton.checked ? Qt.rgba(buttonColor.r, buttonColor.g, buttonColor.b, tabListView.activeFocus ? 0.2 : 0.1) : "transparent"
                    radius: Kirigami.Units.cornerRadius
                }

                PlasmaComponents.Label {
                    id: label
                    anchors.centerIn: parent
                    text: modelData
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: tabListView.dynamicMoveDuration = 0
                    onReleased: Qt.callLater(() => tabListView.dynamicMoveDuration = tabListView.moveDuration)
                    onCanceled: Qt.callLater(() => tabListView.dynamicMoveDuration = tabListView.moveDuration)
                    onClicked: {
                        tabListView.currentIndex = index;
                        tabListView.forceActiveFocus();
                    }
                }
            }
        }

        // Opacity gradient at grid edges
        layer.enabled: !tabListView.fitsEntirely
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                id: maskRect
                width: tabBar.width
                height: tabBar.height

                property real gradientPct: tabListView.defaultMargin / Math.max(1, width)

                gradient: Gradient {
                    orientation: Gradient.Horizontal

                    GradientStop { position: 0; color: 'white' }
                    GradientStop { position: 1.0 - maskRect.gradientPct; color: 'white' }
                    GradientStop { position: 1.0; color: 'transparent' }
                }
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

    onCurrentCategoryIndexChanged: {
        if (folio.HomeScreenState.swipeState !== Folio.HomeScreenState.SwipingAppDrawerCategories) {
            folio.HomeScreenState.goToAppDrawerPage(tabBar.currentIndex, false);
        }
    }
}
