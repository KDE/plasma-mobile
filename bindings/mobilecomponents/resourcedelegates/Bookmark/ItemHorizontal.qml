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

 
import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1 as QtExtraComponents

Item {
    id: resourceItem
    anchors.fill: parent

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


    PlasmaCore.FrameSvgItem {
        imagePath: "widgets/media-delegate"
        prefix: "picture"
        id: frameRect
        height: width/1.6
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    QtExtraComponents.QImageItem {
        id: previewImage
        //fillMode: Image.PreserveAspectCrop
        smooth: true
        width: frameRect.width - 2
        height: frameRect.height - 2
        anchors {
            fill: frameRect
            leftMargin: frameRect.margins.left
            topMargin: frameRect.margins.top
            rightMargin: frameRect.margins.right
            bottomMargin: frameRect.margins.bottom
        }

        image: {
            if (typeof pmSource.data[description] != "undefined") {
                return pmSource.data[description]["thumbnail"];
            }
            if (typeof pmSource.data["fallback"] != "undefined") {
                return pmSource.data["fallback"]["fallbackImage"];
            }
            //QImage("file://home/sebas/Documents/wallpaper.png");
            //var fallback = QImage("file:///home/sebas/Documents/wallpaper.png")
            //return fallback.pixmap(width, height).toImage(); // FIXME: sensible placeholder image
            
            //return fallback;
        }
    }

    PlasmaCore.FrameSvgItem {
        id: textRect
        imagePath: "widgets/translucentbackground"

        width: childrenRect.width + margins.left + margins.right
        height: childrenRect.height + margins.top + margins.bottom
        anchors {
            bottom: parent.bottom
            right: parent.right
        }

        Column {
            anchors {
                top: parent.top
                left: parent.left
                topMargin: textRect.margins.top
                leftMargin: textRect.margins.left
            }
            Text {
                id: textLabel
                color: theme.textColor
                font.pointSize: 16
                style: Text.Sunken;
                styleColor: theme.backgroundColor
                horizontalAlignment: Text.AlignCenter

                opacity: 1
                text: {
                    var s = description;
                    s = s.replace("http://", "");
                    s = s.replace("https://", "");
                    s = s.replace("www.", "");
                    return s;
                }
                anchors.fill: textRect
                //anchors.margins: 16
            }

            MobileComponents.Rating {
                //color: "green"
                id: ratingItem
                score: rating
                resourceUrl: resourceUrl
                opacity: 1
                width: 22*5
                height: 22
                visible: resourceItem.height>70
            }
        }
    }
}