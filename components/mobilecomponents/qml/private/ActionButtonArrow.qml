/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import org.kde.plasma.mobilecomponents 0.2

Canvas {
    id: canvas
    width: height / 1.8
    height: Units.iconSizes.medium - Units.smallSpacing
    property bool inverted
    property color color: {
        if (!mouseArea.pressed) {
            return Theme.backgroundColor;
        }

        if (globalDrawer && globalDrawer.position == 0 &&
            contextDrawer && contextDrawer.position == 0) {
            return Theme.highlightColor;
        }

        if (inverted) {
            if (contextDrawer) {
                return contextDrawer.position > 0 ? Theme.highlightColor : Theme.backgroundColor;
            }
        } else {
            if (globalDrawer) {
                return globalDrawer.position > 0 ? Theme.highlightColor : Theme.backgroundColor;
            }
        }
    }

    anchors.verticalCenter: parent.verticalCenter

    onColorChanged: requestPaint()

    onPaint: {
        var ctx = canvas.getContext("2d");
        ctx.lineWidth = Units.smallSpacing/4
        ctx.strokeStyle = canvas.color;
        ctx.beginPath();
        if (inverted) {
            ctx.moveTo(canvas.width - Units.smallSpacing, Units.smallSpacing);
            ctx.lineTo(Units.smallSpacing, canvas.height/2);
            ctx.lineTo(canvas.width - Units.smallSpacing, canvas.height - Units.smallSpacing);
        } else {
            ctx.moveTo(Units.smallSpacing, Units.smallSpacing);
            ctx.lineTo(canvas.width - Units.smallSpacing, canvas.height/2);
            ctx.lineTo(Units.smallSpacing, canvas.height -Units.smallSpacing);
            //ctx.lineTo(0, canvas.height);
        }
        ctx.stroke();
    }
}

