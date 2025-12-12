// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio
import org.kde.plasma.private.mobileshell as MobileShell

import "./delegate"

// Placeholder item that the user sees as they drag app/folder delegates around.
// See WidgetDragItem for the equivalent for widgets.
Item {
    id: root
    property Folio.HomeScreen folio
    property MobileShell.MaskManager maskManager
    property Folio.FolioDelegate delegate

    width: folio.HomeScreenState.pageCellWidth
    height: folio.HomeScreenState.pageCellHeight

    readonly property real dropAnimationRunning: dragXAnim.running || dragYAnim.running

    // ignore widget dragging, that is not handled by this component
    readonly property bool isWidgetDrag: folio.HomeScreenState.dragState.dropDelegate && folio.HomeScreenState.dragState.dropDelegate.type === Folio.FolioDelegate.Widget

    visible: false
    x: folio.HomeScreenState.delegateDragX
    y: folio.HomeScreenState.delegateDragY

    function setXBinding() {
        x = Qt.binding(() => folio.HomeScreenState.delegateDragX);
    }
    function setYBinding() {
        y = Qt.binding(() => folio.HomeScreenState.delegateDragY);
    }

    // animate drop x
    NumberAnimation on x {
        id: dragXAnim
        running: false
        duration: Kirigami.Units.longDuration
        easing.type: Easing.OutCubic
        onFinished: {
            root.visible = false;
            root.setXBinding();
        }
    }

    // animate drop y
    NumberAnimation on y {
        id: dragYAnim
        running: false
        duration: Kirigami.Units.longDuration
        easing.type: Easing.OutCubic
        onFinished: {
            root.visible = false;
            root.setYBinding();
        }
    }

    // animate scale if it's an app being placed into a folder
    ScaleAnimator on scale {
        id: scaleAnim
        to: 0
        running: false
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutCubic
    }

    Connections {
        id: stateWatcher
        target: folio.HomeScreenState

        property var delegateDroppedOn: null

        // reset and show drag item
        function onDelegateDragStarted() {
            if (isWidgetDrag) {
                return;
            }
            root.scale = 1.0;
            root.visible = true;
        }

        // save the existing delegate at the spot (this is called before the delegate is dropped)
        function onDelegateDragDropped() {
            if (root.isWidgetDrag) {
                return;
            }

            let dragState = folio.HomeScreenState.dragState;
            let dropPosition = dragState.candidateDropPosition;

            switch (dropPosition.location) {
                case Folio.DelegateDragPosition.Pages:
                    stateWatcher.delegateDroppedOn = folio.HomeScreenState.getPageDelegateAt(dropPosition.page, dropPosition.pageRow, dropPosition.pageColumn);
                    break;
                case Folio.DelegateDragPosition.Favourites:
                    stateWatcher.delegateDroppedOn = folio.HomeScreenState.getFavouritesDelegateAt(dropPosition.favouritesPosition);
                    break;
                case Folio.DelegateDragPosition.Folder:
                    stateWatcher.delegateDroppedOn = null;
                    break;
            }
        }

    }

    Connections {
        target: folio.HomeScreenState.dragState

        // animate from when the delegate is dropped to its drop position
        function onDelegateDroppedAndPlaced() {
            if (root.isWidgetDrag) {
                return;
            }

            let dragState = folio.HomeScreenState.dragState;
            let dropPosition = dragState.candidateDropPosition;

            let pos = null;

            switch (dropPosition.location) {
                case Folio.DelegateDragPosition.Pages:
                    pos = folio.HomeScreenState.getPageDelegateScreenPosition(dropPosition.page, dropPosition.pageRow, dropPosition.pageColumn);
                    break;
                case Folio.DelegateDragPosition.Favourites:
                    pos = folio.HomeScreenState.getFavouritesDelegateScreenPosition(dropPosition.favouritesPosition);
                    break;
                case Folio.DelegateDragPosition.Folder:
                    pos = folio.HomeScreenState.getFolderDelegateScreenPosition(dropPosition.folderPosition);
                    break;
            }

            dragXAnim.to = pos.x;
            dragYAnim.to = pos.y;
            dragXAnim.restart();
            dragYAnim.restart();

            if (stateWatcher.delegateDroppedOn &&
                stateWatcher.delegateDroppedOn.type != Folio.FolioDelegate.None &&
                dragState.dropDelegate.type === Folio.FolioDelegate.Application) {

                // scale animation if we are creating, or inserting into a folder
                scaleAnim.restart();
            }
        }

        // if the drop has been abandoned, just hide
        function onNewDelegateDropAbandoned() {
            root.visible = false;
        }
    }

    // simulate an icon delegate
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // icon
        DelegateIconLoader {
            id: loader
            folio: root.folio
            maskManager: root.maskManager
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.minimumWidth: folio.FolioSettings.delegateIconSize
            Layout.minimumHeight: folio.FolioSettings.delegateIconSize
            Layout.preferredHeight: Layout.minimumHeight

            delegate: root.delegate

            layer.enabled: true
            layer.effect: DelegateShadow {}
        }

        // simulate the delegate label for positioning purposes
        DelegateLabel {
            id: label
            opacity: 0

            Layout.fillWidth: true
            Layout.preferredHeight: folio.HomeScreenState.pageDelegateLabelHeight
            Layout.topMargin: folio.HomeScreenState.pageDelegateLabelSpacing
            Layout.leftMargin: -parent.anchors.leftMargin + Kirigami.Units.smallSpacing
            Layout.rightMargin: -parent.anchors.rightMargin + Kirigami.Units.smallSpacing
        }
    }
}
