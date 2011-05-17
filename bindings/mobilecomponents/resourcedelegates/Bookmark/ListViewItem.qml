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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
 
Item {
    id: resourceItem
    height: 204
    width: 240

    PlasmaCore.DataSource {
        id: pmSource
        engine: "preview"
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

    Image {
        id: previewImage
        fillMode: Image.PreserveAspectCrop
        smooth: true
        width: frameRect.width - 2
        height: frameRect.height - 2
        anchors.centerIn: frameRect

        source: {
            if (typeof pmSource.data[description] != "undefined") {
                return pmSource.data[description]["fileName"];
            }
            return "";
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
        rating: rating
        width: 80
        height: 16

        anchors.right: textLabel.right
        anchors.bottom: textRect.bottom
        //margins.bottom: 20
    }
    /*
    MouseArea {
        anchors.fill: parent
        onClicked: {
            print("Opening URL..." + description);
            //plasmoid.openUrl(description);
        }
        / *
        onPressAndHold: {
            //bookmarkSource.connectSource("remove:" + resourceUri);
            print("Bookmark removed: " + resourceUri);
        }
        * /
    }
    */
}