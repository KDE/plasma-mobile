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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1


Item {
    property int score
    property string resourceUrl
    height: 22
    width: 22*5

    Row {
        id: iconRow
        anchors.centerIn: parent
        spacing: 0
        Repeater {
            model: 5

            QIconItem {
                width: 22
                height: 22
                icon: QIcon("rating")
                property int baseRating: (index+1)*2
                enabled: (score > index*2)
            }
        }
    }


    MouseArea {
        anchors.fill: parent

        onReleased: {
            var star = iconRow.childAt(mouse.x, mouse.y);
            if (star && star.baseRating) {
                if (resourceUrl) {
                    print("released with rating " + star.baseRating + " Item: " + resourceUrl);
                    rateResource(resourceUrl, star.baseRating);
                } else {
                    score = star.baseRating
                }
            } else{
                print("released but could not figure out rating" + star);
            }
        }
    }


    function rateResource(resourceUrl, rating) {
        print("New Rating " + resourceUrl + " *****: " + rating )
        if (resourceUrl == "") {
            print("url empty.");
            return;
        }
        var service = metadataSource.serviceForSource("anything")
        var operation = service.operationDescription("rate")

        operation["ResourceUrl"] = resourceUrl;
        operation["Rating"] = rating;
        service.startOperationCall(operation)
    }

}
