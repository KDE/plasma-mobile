/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1 as QtExtraComponents

Item {
    id: resourceItem
    anchors.fill: parent

    PlasmaCore.DataSource {
        id: pmSource
        engine: "org.kde.preview"
        connectedSources: [ description ]
        interval: 0
    }

    PlasmaCore.DataSource {
        id: bookmarkSource
        engine: "org.kde.active.bookmarks"
        interval: 0
    }

    PlasmaCore.Theme {
        id: theme
    }


    Rectangle {
        id: frameRect
        anchors {
            top: parent.top;
            left: parent.left;
            margins: 12;
        }
        width: 182
        height: 122
        color: theme.textColor
        opacity: .6
        radius: 1
    }

    QtExtraComponents.QImageItem {
        id: previewImage
        //fillMode: Image.PreserveAspectCrop
        //smooth: true
        width: frameRect.width - 2
        height: frameRect.height - 2
        anchors.centerIn: frameRect

        image: {
            if (typeof pmSource.data[description] != "undefined") {
                return pmSource.data[description]["thumbnail"];
            }
            return; // FIXME: sensible placeholder image
        }
    }

    Rectangle {
        id: textRect
        width: 160
        height: 48
        color: theme.backgroundColor
        radius: 4
        opacity: .8
        anchors {
            bottom: frameRect.bottom
            right: parent.right
            margins: 10
        }
    }

    Text {
        id: textLabel
        color: theme.textColor
        font.pointSize: 16
        style: Text.Sunken;
        styleColor: theme.backgroundColor
        horizontalAlignment: Text.AlignRight
        text: {
            var s = description;
            s = s.replace("http://", "");
            s = s.replace("https://", "");
            s = s.replace("www.", "");
            return s;
        }
        anchors.fill: textRect
        anchors.margins: 4
    }

    MobileComponents.Rating {
        //color: "green"
        id: ratingItem
        score: rating
        //width: 22*5
        //height: 22

        anchors.right: textLabel.right
        anchors.bottom: textRect.bottom
        //margins.bottom: 20
    }
}