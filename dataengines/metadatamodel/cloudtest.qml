/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

import QtQuick 1.1
import org.kde.plasma.components 0.1
import org.kde.datamodels 0.1

Item {
    width: 800
    height: 480

    

    ListView {
        id: metadataList
        clip: true
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }

        model: MetadataCloudModel {
            id: metadataCloudModel
            cloudCategory: "kext:Activity"
            //queryString: "pdf"
            //resourceType: "nfo:Document"
            //activityId: "12c8a6ea-c99b-4a54-bf42-a4e8fbcb9be7"
            //sortBy: ["nie#url", "nao#lastModified"]
        }

        delegate: Row {
            spacing: 10
            Text {
                text: model["label"]
            }
            Text {
                text: model["count"]
            }
        }
    }

    ScrollDecorator {
        flickableItem: metadataList
        orientation: Qt.Vertical
        anchors {
            top:metadataList.top
            right:metadataList.right
            bottom:metadataList.bottom
        }
    }
}