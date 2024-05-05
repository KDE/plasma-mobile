/*
 *  SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.1
import QtQml 2.15

import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.kwindowsystem 1.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.shell.panel 0.1 as Panel

import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    // NOTE: Plasma Mobile specific:
    Connections {
        target: root
        
        function onContainmentChanged() { 
            // HACK: add PanelView into the containment so that it can be used
            if (containment.panel !== undefined) {
                containment.panel = panel;
            }
            if (containment.tabBar !== undefined) {
                containment.tabBar = tabBar;
            }
        }
    }

    // NOTE: Below is taken straight out of Plasma Desktop so that we can 
    //       support desktop panels properly, try to keep it in sync:
    //       plasma-desktop/desktoppackage/contents/views/Panel.qml

    property Item containment

    property bool floatingPrefix: floatingPanelSvg.usedPrefix === "floating"
    readonly property bool verticalPanel: containment?.plasmoid?.formFactor === PlasmaCore.Types.Vertical

    readonly property real spacingAtMinSize: Math.round(Math.max(1, (verticalPanel ? root.width : root.height) - Kirigami.Units.iconSizes.smallMedium)/2)
    KSvg.FrameSvgItem {
        id: thickPanelSvg
        visible: false
        prefix: 'thick'
        imagePath: "widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: floatingPanelSvg
        visible: false
        prefix: ['floating', '']
        imagePath: "widgets/panel-background"
    }

    readonly property bool topEdge: containment?.plasmoid?.location === PlasmaCore.Types.TopEdge
    readonly property bool leftEdge: containment?.plasmoid?.location === PlasmaCore.Types.LeftEdge
    readonly property bool rightEdge: containment?.plasmoid?.location === PlasmaCore.Types.RightEdge
    readonly property bool bottomEdge: containment?.plasmoid?.location === PlasmaCore.Types.BottomEdge

    readonly property int topPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.top + Kirigami.Units.smallSpacing, spacingAtMinSize));
    readonly property int bottomPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.bottom + Kirigami.Units.smallSpacing, spacingAtMinSize));
    readonly property int leftPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.left + Kirigami.Units.smallSpacing, spacingAtMinSize));
    readonly property int rightPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.right + Kirigami.Units.smallSpacing, spacingAtMinSize));

    readonly property int fixedBottomFloatingPadding: floating && (floatingPrefix ? floatingPanelSvg.fixedMargins.bottom : 8)
    readonly property int fixedLeftFloatingPadding: floating && (floatingPrefix ? floatingPanelSvg.fixedMargins.left   : 8)
    readonly property int fixedRightFloatingPadding: floating && (floatingPrefix ? floatingPanelSvg.fixedMargins.right  : 8)
    readonly property int fixedTopFloatingPadding: floating && (floatingPrefix ? floatingPanelSvg.fixedMargins.top    : 8)

    readonly property int bottomFloatingPadding: Math.round(fixedBottomFloatingPadding * floatingness)
    readonly property int leftFloatingPadding: Math.round(fixedLeftFloatingPadding * floatingness)
    readonly property int rightFloatingPadding: Math.round(fixedRightFloatingPadding * floatingness)
    readonly property int topFloatingPadding: Math.round(fixedTopFloatingPadding * floatingness)

    readonly property int minPanelHeight: translucentItem.minimumDrawingHeight
    readonly property int minPanelWidth: translucentItem.minimumDrawingWidth

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    property bool touchingWindow: visibleWindowsModel.count > 0

    TaskManager.TasksModel {
        id: visibleWindowsModel
        filterByVirtualDesktop: true
        filterByActivity: true
        filterByScreen: true
        filterByRegion: TaskManager.RegionFilterMode.Intersect
        filterHidden: true
        filterMinimized: true

        screenGeometry: panel.screenGeometry
        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity

        groupMode: TaskManager.TasksModel.GroupDisabled

        Binding on regionGeometry {
            delayed: true
            property real verticalMargin: (fixedTopFloatingPadding + fixedBottomFloatingPadding) * (1 - floatingness)
            property real horizontalMargin: (fixedLeftFloatingPadding + fixedRightFloatingPadding) * (1 - floatingness)
            // This makes the panel de-float when a window is 6px from it or less.
            // 6px is chosen to avoid any potential issue with kwin snapping behavior,
            // and it looks like the panel hides away from the active window.
            value: floatingness, panel.width, panel.height, panel.x, panel.y, panel.geometryByDistance(6 + (verticalPanel ? horizontalMargin : verticalMargin))
        }
    }

    Connections {
        target: containment
        function onActivated() {
            // BUG 472909: status changes to PassiveStatus or ActiveStatus after applet shortcut is pressed for the second time
            if (containment.status === PlasmaCore.Types.PassiveStatus /*After pressing panel shortcut*/ || containment.status === PlasmaCore.Types.ActiveStatus) {
                containment.status = PlasmaCore.Types.AcceptingInputStatus;
                // BUG 472909: if applet shortcut is pressed, panel also gets activated, but status will change to RequiresAttentionStatus after applet has focus
            } else /* Panel has focus, or applet has focus */ {
                containment.status = PlasmaCore.Types.PassiveStatus;
            }
        }
    }

    // Floatingness is a value in [0, 1] that's multiplied to the floating margin; 0: not floating, 1: floating, between 0 and 1: animation between the two states
    property double floatingness
    // PanelOpacity is a value in [0, 1] that's used as the opacity of the opaque elements over the transparent ones; values between 0 and 1 are used for animations
    property double panelOpacity
    Behavior on floatingness {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }
    Behavior on panelOpacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    // This value is read from panelview.cpp and disables shadow for floating panels, as they'd be detached from the panel
    property bool hasShadows: floatingness < 0.5
    property var panelMask: floatingness === 0 ? (panelOpacity === 1 ? opaqueItem.mask : translucentItem.mask) : (panelOpacity === 1 ? floatingOpaqueItem.mask : floatingTranslucentItem.mask)

    // These two values are read from panelview.cpp and are used as an offset for the mask
    property int maskOffsetX: floatingTranslucentItem.x
    property int maskOffsetY: floatingTranslucentItem.y

    KSvg.FrameSvgItem {
        id: translucentItem
        visible: floatingness === 0 && panelOpacity !== 1
        enabledBorders: panel.enabledBorders
        anchors.fill: floatingTranslucentItem
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: floatingTranslucentItem
        visible: floatingness !== 0 && panelOpacity !== 1
        x: root.leftEdge ? fixedLeftFloatingPadding + fixedRightFloatingPadding * (1 - floatingness) : leftFloatingPadding
        y: root.topEdge ? fixedTopFloatingPadding + fixedBottomFloatingPadding * (1 - floatingness) : topFloatingPadding
        width: verticalPanel ? panel.thickness : parent.width - leftFloatingPadding - rightFloatingPadding
        height: verticalPanel ? parent.height - topFloatingPadding - bottomFloatingPadding : panel.thickness

        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: floatingOpaqueItem
        visible: floatingness !== 0 && panelOpacity !== 0
        opacity: panelOpacity
        anchors.fill: floatingTranslucentItem
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "solid/widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: opaqueItem
        visible: panelOpacity !== 0 && floatingness === 0
        opacity: panelOpacity
        enabledBorders: panel.enabledBorders
        anchors.fill: floatingTranslucentItem
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "solid/widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: floatingShadow
        visible: !hasShadows
        z: -100
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "solid/widgets/panel-background"
        prefix: "shadow"
        anchors {
            fill: floatingTranslucentItem
            topMargin: -floatingShadow.margins.top
            leftMargin: -floatingShadow.margins.left
            rightMargin: -floatingShadow.margins.right
            bottomMargin: -floatingShadow.margins.bottom
        }
    }

    Keys.onEscapePressed: {
        root.parent.focus = false
    }

    property bool isOpaque: panel.opacityMode === Panel.Global.Opaque
    property bool isTransparent: panel.opacityMode === Panel.Global.Translucent
    property bool isAdaptive: panel.opacityMode === Panel.Global.Adaptive
    property bool floating: panel.floating
    readonly property bool screenCovered: !KWindowSystem.showingDesktop && touchingWindow && panel.visibilityMode == Panel.Global.NormalPanel
    property var stateTriggers: [floating, screenCovered, isOpaque, isAdaptive, isTransparent]
    onStateTriggersChanged: {
        let opaqueApplets = false
        let floatingApplets = false
        if ((!floating || screenCovered) && (isOpaque || (screenCovered && isAdaptive))) {
            panelOpacity = 1
            opaqueApplets = true
            floatingness = 0
        } else if ((!floating || screenCovered) && (isTransparent || (!screenCovered && isAdaptive))) {
            panelOpacity = 0
            floatingness = 0
        } else if ((floating && !screenCovered) && (isTransparent || isAdaptive)) {
            panelOpacity = 0
            floatingness = 1
            floatingApplets = true
        } else if (floating && !screenCovered && isOpaque) {
            panelOpacity = 1
            opaqueApplets = true
            floatingness = 1
            floatingApplets = true
        }
        if (!KWindowSystem.isPlatformWayland) {
            opaqueApplets = false
            panelOpacity = 0
        }
        // Not using panelOpacity to check as it has a NumberAnimation, and it will thus
        // be still read as the initial value here, before the animation starts.
        if (containment) {
            if (opaqueApplets) {
                containment.plasmoid.containmentDisplayHints |= PlasmaCore.Types.ContainmentPrefersOpaqueBackground
            } else {
                containment.plasmoid.containmentDisplayHints &= ~PlasmaCore.Types.ContainmentPrefersOpaqueBackground
            }
            if (floatingApplets) {
                containment.plasmoid.containmentDisplayHints |= PlasmaCore.Types.ContainmentPrefersFloatingApplets
            } else {
                containment.plasmoid.containmentDisplayHints &= ~PlasmaCore.Types.ContainmentPrefersFloatingApplets
            }
        }
    }

    function adjustPrefix() {
        if (!containment) {
            return "";
        }
        var pre;
        switch (containment.plasmoid.location) {
        case PlasmaCore.Types.LeftEdge:
            pre = "west";
            break;
        case PlasmaCore.Types.TopEdge:
            pre = "north";
            break;
        case PlasmaCore.Types.RightEdge:
            pre = "east";
            break;
        case PlasmaCore.Types.BottomEdge:
            pre = "south";
            break;
        default:
            pre = "";
            break;
        }
        translucentItem.prefix = opaqueItem.prefix = floatingTranslucentItem.prefix = floatingOpaqueItem.prefix = [pre, ""];
    }

    onContainmentChanged: {
        if (!containment) {
            return;
        }
        containment.parent = containmentParent;
        containment.visible = true;
        containment.anchors.fill = containmentParent;
        containment.plasmoid.locationChanged.connect(adjustPrefix);
        adjustPrefix();
    }

    Binding {
        target: panel
        property: "length"
        when: containment
        delayed: true
        value: {
            if (!containment) {
                return;
            }
            if (verticalPanel) {
                return containment.Layout.preferredHeight
            } else {
                return containment.Layout.preferredWidth
            }
        }
        restoreMode: Binding.RestoreBinding
    }

    Binding {
        target: panel
        property: "backgroundHints"
        when: containment
        value: {
            if (!containment) {
                return;
            }

            return containment.plasmoid.backgroundHints;
        }
        restoreMode: Binding.RestoreBinding
    }

    KSvg.FrameSvgItem {
        id: tabBar
        x: root.verticalPanel || !panel.activeFocusItem
            ? 0
            : Math.max(panel.activeFocusItem.Kirigami.ScenePosition.x, panel.activeFocusItem.Kirigami.ScenePosition.x)
        y: root.verticalPanel && panel.activeFocusItem
            ? Math.max(panel.activeFocusItem.Kirigami.ScenePosition.y, panel.activeFocusItem.Kirigami.ScenePosition.y)
            : 0

        width: panel.activeFocusItem
            ? (root.verticalPanel ? root.width : Math.min(panel.activeFocusItem.width, panel.activeFocusItem.width))
            : 0
        height: panel.activeFocusItem
            ? (root.verticalPanel ?  Math.min(panel.activeFocusItem.height, panel.activeFocusItem.height) : root.height)
            : 0

        visible: panel.active && panel.activeFocusItem

        imagePath: "widgets/tabbar"
        prefix: {
            if (!root.containment) {
                return "";
            }
            var prefix = ""
            switch (root.containment.plasmoid.location) {
                case PlasmaCore.Types.LeftEdge:
                    prefix = "west-active-tab";
                    break;
                case PlasmaCore.Types.TopEdge:
                    prefix = "north-active-tab";
                    break;
                case PlasmaCore.Types.RightEdge:
                    prefix = "east-active-tab";
                    break;
                default:
                    prefix = "south-active-tab";
            }
            if (!hasElementPrefix(prefix)) {
                prefix = "active-tab";
            }
            return prefix;
        }
    }
    Item {
        id: containmentParent
        anchors.centerIn: isOpaque ? floatingOpaqueItem : floatingTranslucentItem
        width: root.verticalPanel ? panel.thickness : root.width - root.floatingness * (fixedLeftFloatingPadding + fixedRightFloatingPadding)
        height: root.verticalPanel ? root.height - root.floatingness * (fixedBottomFloatingPadding - fixedTopFloatingPadding) : panel.thickness
    }

}
