/*
 *   Copyright 2011, 2015 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2011 Viranch Mehta <viranch.mehta@gmail.com>
 *   Copyright 2013-2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0


Item {
    id: batterymonitor
    width: units.gridUnit * 11
    height: units.gridUnit * 11
    Plasmoid.switchWidth: units.gridUnit * 10
    Plasmoid.switchHeight: units.gridUnit * 10

    LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property bool disableBrightnessUpdate: false

    property int screenBrightness
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0


    onScreenBrightnessChanged: {
        if (disableBrightnessUpdate) {
            return;
        }
        var service = pmSource.serviceForSource("PowerDevil");
        var operation = service.operationDescription("setBrightness");
        operation.brightness = screenBrightness;
        // show OSD only when the plasmoid isn't expanded since the moving slider is feedback enough
        operation.silent = plasmoid.expanded
        service.startOperationCall(operation);
    }

    function action_powerdevilkcm() {
        // FIXME: replace
        KCMShell.open(["powerdevilprofilesconfig", "powerdevilactivitiesconfig", "powerdevilglobalconfig"]);
    }

    function updateBrightness(rootItem, source) {
        if (!source.data["PowerDevil"]) {
            print("No powerdevil");
            return;
        }

        // we don't want passive brightness change send setBrightness call
        rootItem.disableBrightnessUpdate = true;

        if (typeof source.data["PowerDevil"]["Screen Brightness"] === 'number') {
            rootItem.screenBrightness = source.data["PowerDevil"]["Screen Brightness"];
        }
        rootItem.disableBrightnessUpdate = false;
    }

    Component.onCompleted: {
        updateBrightness(batterymonitor, pmSource);
        plasmoid.removeAction("configure");
        plasmoid.setAction("powerdevilkcm", i18n("&Configure Power Saving..."), "preferences-system-power-management");
    }

    function updateLogic() {
        plasmoid.status = plasmoidStatus();
//         Logic.updateTooltip(batterymonitor.remainingTime);
    }

    function stringForBatteryState(batteryData) {
        if (batteryData["Plugged in"]) {
            switch(batteryData["State"]) {
                case "NoCharge": return i18n("Not Charging");
                case "Discharging": return i18n("Discharging");
                case "FullyCharged": return i18n("Fully Charged");
                default: return i18n("Charging");
            }
        } else {
            return i18nc("Battery is currently not present in the bay","Not present");
        }
    }
    
    function plasmoidStatus() {
        var status = PlasmaCore.Types.PassiveStatus;
        if (powermanagementDisabled) {
            status = PlasmaCore.Types.ActiveStatus;
        }

        if (pmSource.data["Battery"]["Has Cumulative"]) {
            if (pmSource.data["Battery"]["State"] !== "Charging" && pmSource.data["Battery"]["Percent"] <= 5) {
                status = PlasmaCore.Types.NeedsAttentionStatus
            } else if (pmSource.data["Battery"]["State"] !== "FullyCharged") {
                status = PlasmaCore.Types.ActiveStatus
            }
        }

        return status;
    }

    Plasmoid.compactRepresentation: MouseArea {
        Layout.minimumWidth: batteryLayout.implicitWidth
        Layout.minimumHeight: batteryLayout.implicitHeight

        property bool wasExpanded: false
        onPressed: {
            if (mouse.button == Qt.LeftButton) {
                wasExpanded = plasmoid.expanded;
            } else if (mouse.button == Qt.MiddleButton) {
                muteVolume();
            }
        }
        onClicked: {
            if (mouse.button == Qt.LeftButton) {
                plasmoid.expanded = !wasExpanded;
            }
        }
        RowLayout {
            id: batteryLayout
            anchors.fill: parent
            spacing: 0
            PlasmaComponents.Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                font.pixelSize: theme.smallestFont.pixelSize
                text: pmSource.data["Battery"]["Percent"]
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
            BatteryIcon {
                id: batteryIcon
                Layout.minimumWidth: height
                Layout.maximumWidth: height
                Layout.fillHeight: true
                hasBattery: true
                percent: pmSource.data["Battery"]["Percent"]
                //pluggedIn: batteryContainer.pluggedIn
        //         height: batteryContainer.iconSize
        //         width: height
            }
        }
    }

    Plasmoid.fullRepresentation: ExpandedRepresentation {


    }

    property QtObject pmSource: PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: sources
        onSourceAdded: {
            disconnectSource(source);
            connectSource(source);
        }
        onSourceRemoved: {
            disconnectSource(source);
        }
        /* FIXME: Brightness-related, but needs support lower in the stack first
        onDataChanged: {
            updateBrightness(batterymonitor, pmSource)
        }
        Component.onCompleted: {
            print("Connecting powerdevil");
            connectSource("PowerDevil");
        }
        */
    }
}
