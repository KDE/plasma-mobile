// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: batterymonitor
    width: 48
    height: 48

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["AC Adapter", "Battery", "Battery0"]
        interval: 0
    }

    PlasmaCore.Svg{
        id: iconSvg
        imagePath: "icons/battery"
    }

    PlasmaCore.SvgItem {
        anchors.fill: parent
        svg: iconSvg
        elementId: "Battery"
    }

    PlasmaCore.SvgItem {
        anchors.fill: parent
        svg: iconSvg
        elementId: fillElement(pmSource.data["Battery0"]["Percent"]) 
    }

    function fillElement(p) {
        if (p >= 100) {
            return "Fill100";
        } else if (p > 80) {
            return "Fill80";
        } else if (p > 60) {
            return "Fill60";
        } else if (p > 40) {
            return "Fill40";
        } else if (p > 20) {
            return "Fill20";
        }
        return "";
    }

    PlasmaCore.SvgItem {
        anchors.fill: parent
        svg: iconSvg
        elementId: pmSource.data["AC Adapter"]["Plugged in"] ? "AcAdapter" : ""
    }
}
