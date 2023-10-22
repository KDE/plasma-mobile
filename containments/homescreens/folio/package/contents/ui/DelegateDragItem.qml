// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.private.mobile.homescreen.folio 1.0 as Folio

import "./delegate"

Item {
    id: root
    width: Folio.HomeScreenState.pageCellWidth
    height: Folio.HomeScreenState.pageCellHeight

    property Folio.FolioDelegate delegate

    readonly property real dropAnimationRunning: dragXAnim.running || dragYAnim.running

    visible: false
    x: Math.round(Folio.HomeScreenState.delegateDragX)
    y: Math.round(Folio.HomeScreenState.delegateDragY)

    function setXBinding() {
        x = Qt.binding(() => Math.round(Folio.HomeScreenState.delegateDragX));
    }
    function setYBinding() {
        y = Qt.binding(() => Math.round(Folio.HomeScreenState.delegateDragY));
    }

    // animate drop x
    XAnimator on x {
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
    YAnimator on y {
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
        target: Folio.HomeScreenState

        property var delegateDroppedOn: null

        // reset and show drag item
        function onSwipeStateChanged() {
            if (Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate) {
                root.scale = 1.0;
                root.visible = true;
            }
        }

        // save the existing delegate at the spot (this is called before the delegate is dropped)
        function onDelegateDragEnded() {
            let dragState = Folio.HomeScreenState.dragState;
            let dropPosition = dragState.candidateDropPosition;

            switch (dropPosition.location) {
                case Folio.DelegateDragPosition.Pages:
                    stateWatcher.delegateDroppedOn = Folio.HomeScreenState.getPageDelegateAt(dropPosition.page, dropPosition.pageRow, dropPosition.pageColumn);
                    break;
                case Folio.DelegateDragPosition.Favourites:
                    stateWatcher.delegateDroppedOn = Folio.HomeScreenState.getFavouritesDelegateAt(dropPosition.favouritesPosition);
                    break;
                case Folio.DelegateDragPosition.Folder:
                    stateWatcher.delegateDroppedOn = null
                    break;
            }
        }
    }

    Connections {
        target: Folio.HomeScreenState.dragState

        // animate from when the delegate is dropped to its drop position
        function onDelegateDroppedAndPlaced() {
            let dragState = Folio.HomeScreenState.dragState;
            let dropPosition = dragState.candidateDropPosition;

            let pos = null;

            switch (dropPosition.location) {
                case Folio.DelegateDragPosition.Pages:
                    pos = Folio.HomeScreenState.getPageDelegateScreenPosition(dropPosition.page, dropPosition.pageRow, dropPosition.pageColumn);
                    break;
                case Folio.DelegateDragPosition.Favourites:
                    pos = Folio.HomeScreenState.getFavouritesDelegateScreenPosition(dropPosition.favouritesPosition);
                    break;
                case Folio.DelegateDragPosition.Folder:
                    pos = Folio.HomeScreenState.getFolderDelegateScreenPosition(dropPosition.folderPosition);
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
    }

    // simulate an icon delegate
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // icon
        DelegateIconLoader {
            id: loader
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.minimumWidth: Folio.FolioSettings.delegateIconSize
            Layout.minimumHeight: Folio.FolioSettings.delegateIconSize
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
            Layout.preferredHeight: Folio.HomeScreenState.pageDelegateLabelHeight
            Layout.topMargin: Folio.HomeScreenState.pageDelegateLabelSpacing
            Layout.leftMargin: -parent.anchors.leftMargin + Kirigami.Units.smallSpacing
            Layout.rightMargin: -parent.anchors.rightMargin + Kirigami.Units.smallSpacing
        }
    }
}
