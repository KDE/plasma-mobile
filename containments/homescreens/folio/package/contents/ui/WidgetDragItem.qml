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
import org.kde.private.mobile.homescreen.folio 1.0 as Folio

import './delegate'
import './private'

Item {
    id: root
    width: widgetLoader.item ? widgetLoader.item.width : 0
    height: widgetLoader.item ? widgetLoader.item.height : 0

    property Folio.FolioWidget widget

    readonly property bool isWidgetDelegate: Folio.HomeScreenState.dragState.dropDelegate && Folio.HomeScreenState.dragState.dropDelegate.type === Folio.FolioDelegate.Widget
    readonly property bool dropAnimationRunning: dragXAnim.running || dragYAnim.running

    visible: false
    x: Math.round(Folio.HomeScreenState.delegateDragX)
    y: Math.round(Folio.HomeScreenState.delegateDragY)

    function startDrag(widget) {
        root.widget = widget;
        visible = true;
    }

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
            root.widget = null;
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
            root.widget = null;
            root.setYBinding();
        }
    }

    Connections {
        id: stateWatcher
        target: Folio.HomeScreenState

        function onSwipeStateChanged() {
            if (Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate &&
                Folio.HomeScreenState.dragState.dropDelegate &&
                Folio.HomeScreenState.dragState.dropDelegate.type === Folio.FolioDelegate.Widget) {

                root.startDrag(Folio.HomeScreenState.dragState.dropDelegate.widget);
            }
        }
    }

    Connections {
        target: Folio.HomeScreenState.dragState

        // animate from when the delegate is dropped to its drop position
        function onDelegateDroppedAndPlaced() {
            if (!root.isWidgetDelegate) {
                return;
            }

            let dragState = Folio.HomeScreenState.dragState;
            let dropPosition = dragState.candidateDropPosition;

            let pos = Folio.HomeScreenState.getPageDelegateScreenPosition(dropPosition.page, dropPosition.pageRow, dropPosition.pageColumn);

            dragXAnim.to = pos.x;
            dragYAnim.to = pos.y;
            dragXAnim.restart();
            dragYAnim.restart();
        }

        // if the drop has been abandoned, just hide
        function onNewDelegateDropAbandoned() {
            root.visible = false;
        }
    }

    Loader {
        id: widgetLoader

        active: root.widget

        sourceComponent: WidgetDelegate {
            widget: root.widget

            layer.enabled: true
            layer.effect: DarkenEffect {}
        }
    }
}
