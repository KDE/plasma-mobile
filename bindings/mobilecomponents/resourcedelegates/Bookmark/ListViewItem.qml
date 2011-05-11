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

        Component.onCompleted: {
            //print("connected:" + connectedSources);
        }

        onDataUpdated: {
            //print(" dataUpdated: " + source + data);
        }
    }

    PlasmaCore.Theme {
        id: theme
    }


    Rectangle {
        id: frameRect
        anchors {
            top: parent.top;
            left: parent.left;
            //right: textLabel.left;
            margins: 12;
        }
        width: 180
        height: 121
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
        height: 32
        color: theme.backgroundColor
        radius: 4
        opacity: .8
        anchors {
            bottom: frameRect.bottom
            //left: frameRect.left
            right: parent.right
            margins: 10
        }
    }
    /*
    Rectangle {
        border.color: theme.textColor
        anchors.fill: previewImage
        //spacing: 3
        border.width: 3
        opacity: .3
    }
    */
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
        /*
        anchors {
            right: parent.right;
            bottom: previewImage.bottom;
            left: previewImage.right;
            margins: 12
            //margins: 4;
        }
        */
    }

}