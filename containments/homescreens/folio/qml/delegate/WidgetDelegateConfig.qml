// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg

import org.kde.plasma.components 3.0 as PC3
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

import '../private'

Item {
    id: root
    property Folio.HomeScreen folio

    property var homeScreen

    property int pageNum
    property int row
    property int column

    property real widgetWidth
    property real widgetHeight
    property real widgetX
    property real widgetY

    property real topWidgetBackgroundPadding
    property real bottomWidgetBackgroundPadding
    property real leftWidgetBackgroundPadding
    property real rightWidgetBackgroundPadding

    property Folio.FolioPageDelegate pageDelegate
    property Folio.FolioWidget widget
    property var pageModel

    signal removeRequested()
    signal closed()

    function startOpen() {
        // prevent config overlay if lock layout is enabled
        if (folio.FolioSettings.lockLayout) return;
        configOverlay.open();
    }

    function fullyOpen() {
        configPopup.open();
        configOverlay.close();
    }

    // HACK: this shows the config when we are in the "press to hold" state, prior to mouse release
    // we can't just open the popup, because the potential drag-and-drop swipe would get lost
    MouseArea {
        id: configOverlay
        parent: root.homeScreen
        anchors.fill: parent

        width: configPopup.width
        height: configPopup.height

        opacity: 0
        visible: opacity > 0

        // in case this gets stuck open over the homescreen, just close on tap
        onClicked: close()

        NumberAnimation on opacity { id: configOverlayOpacityAnim; duration: 200 }

        function open() {
            configOverlayOpacityAnim.to = 1;
            configOverlayOpacityAnim.restart();
        }

        function animClose() {
            if (opacity !== 0) {
                configOverlayOpacityAnim.to = 0;
                configOverlayOpacityAnim.restart();
            }
        }

        function close() {
            opacity = 0;
        }

        Connections {
            target: folio.HomeScreenState

            // if we are starting drag-and-drop, close the menu immediately
            function onSwipeStateChanged() {
                if (folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate) {
                    configOverlay.animClose();
                    root.closed();
                }
            }
        }

        // the config overlay
        FastBlur {
            anchors.fill: parent
            source: configPopup.contentItem
            radius: 0
        }
    }

    // this is the actual interactive popup for widget settings, only
    // opened when the user releases their press (and doesn't drag)
    QQC2.Popup {
        id: configPopup
        width: root.homeScreen.width
        height: root.homeScreen.height
        parent: root.homeScreen

        onClosed: {
            configOverlay.close(); // ensure overlay is closed
            root.closed();
        }

        topPadding: 0
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0

        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutsideParent

        readonly property real barWidth: Kirigami.Units.gridUnit * 3.5
        readonly property real barSpacing: Kirigami.Units.largeSpacing
        readonly property real minimumBarLength: Kirigami.Units.gridUnit * 8

        background: Item {}
        QQC2.Overlay.modal: Item {}

        exit: Transition {
            NumberAnimation { property: "opacity"; duration: 200; from: 1.0; to: 0.0 }
        }

        Connections {
            target: folio.HomeScreenState

            // don't show config overlay if we have navigated to another page
            function onCurrentPageChanged() {
                if (configPopup.visible) {
                    configPopup.close();
                }
            }
        }

        contentItem: MouseArea {
            id: configItem

            onClicked: configPopup.close()

            WidgetResizeHandleFrame {
                id: resizeFrame
                folio: root.folio
                anchors.fill: parent

                widgetWidth: root.widgetWidth
                widgetHeight: root.widgetHeight
                widgetX: root.widgetX + root.leftWidgetBackgroundPadding
                widgetY: root.widgetY + root.topWidgetBackgroundPadding

                widgetTopMargin: root.topWidgetBackgroundPadding
                widgetBottomMargin: root.bottomWidgetBackgroundPadding
                widgetLeftMargin: root.leftWidgetBackgroundPadding
                widgetRightMargin: root.rightWidgetBackgroundPadding

                widgetRow: root.row
                widgetColumn: root.column
                widgetGridWidth: root.widget.gridWidth
                widgetGridHeight: root.widget.gridHeight

                onWidgetChangeAfterDrag: (widgetRow, widgetColumn, widgetGridWidth, widgetGridHeight) => {
                    if (resizeFrame.lockDrag !== null) triggerWidgetChanges(widgetRow, widgetColumn, widgetGridWidth, widgetGridHeight);
                }

                function triggerWidgetChanges(widgetRow, widgetColumn, widgetGridWidth, widgetGridHeight) {
                    root.pageModel.moveAndResizeWidgetDelegate(
                        root.pageDelegate,
                        widgetRow,
                        widgetColumn,
                        widgetGridWidth,
                        widgetGridHeight
                    );
                }
            }

            PC3.Button {
                id: button
                icon.name: 'settings-configure'
                text: i18n('Options')
                display: (resizeFrame.handleContainer.width > Kirigami.Units.gridUnit * 7) ? PC3.Button.TextBesideIcon : PC3.Button.IconOnly

                readonly property var handleContainer: resizeFrame.handleContainer
                x: Math.round(handleContainer.x + (handleContainer.width / 2) - (width / 2))
                y: Math.round(handleContainer.y + (handleContainer.height / 2) - (height / 2))

                onClicked: contextMenuDialog.open()
            }

            Kirigami.Dialog {
                id: contextMenuDialog
                preferredWidth: Kirigami.Units.gridUnit * 20
                padding: 0
                title: i18n('Widget Options')

                // workaround: remove background so that it doesn't remain if the widget is deleted (and this is de-initialized without closing)
                QQC2.Overlay.modal: null

                // close parent dialog too
                onClosed: configPopup.close()

                ColumnLayout {
                    id: column
                    spacing: 0

                    Repeater {
                        model: root.widget.applet ? [...root.widget.applet.contextualActions, configureAppletAction, removeDelegateAction] : [removeDelegateAction]

                        delegate: QQC2.ItemDelegate {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Kirigami.Units.gridUnit * 2

                            action: modelData
                            text: modelData.text
                            icon.name: modelData.icon.name

                            icon.width: Kirigami.Units.gridUnit
                            icon.height: Kirigami.Units.gridUnit

                            leftPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                            rightPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing

                            onClicked: contextMenuDialog.close()
                        }
                    }
                }
            }
        }
    }

    Kirigami.Action {
        id: removeDelegateAction
        icon.name: 'edit-delete-remove'
        text: i18n('Remove widget')
        onTriggered: root.removeRequested()
    }

    Kirigami.Action {
        id: configureAppletAction
        icon.name: 'settings-configure'
        text: i18n('Configure widget')
        onTriggered: root.widget.applet.internalAction('configure').trigger();
    }
}
