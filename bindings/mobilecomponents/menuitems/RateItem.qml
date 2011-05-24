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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents


Item {
    property int score
    property string resourceUrl
    property int implicitHeight: 22
    property int implicitWidth: 22*5
    signal rateClicked(int newRating)

    Row {
        id: iconRow
        spacing: 0
        MobileComponents.RatingIcon {
            id: rating2
            baseRating: 2
        }
        MobileComponents.RatingIcon {
            id: rating4
            baseRating: 4
        }
        MobileComponents.RatingIcon {
            id: rating6
            baseRating: 6
        }
        MobileComponents.RatingIcon {
            id: rating8
            baseRating: 8
        }
        MobileComponents.RatingIcon {
            id: rating10
            baseRating: 10
        }
    }

    onScoreChanged: {
        //print ("XXX :-) rating changed to " + score);
        updateIcons(score);
    }

    onResourceUrlChanged: {
        print("someone poked resourceUrl");
    }

    Component.onCompleted: {
        if (score > 0) {
            //print("XXX done, rating " + score);
        }
        updateIcons(score);
    }

    MouseArea {
        anchors.fill: parent

        onReleased: {
            var star = iconRow.childAt(mouse.x, mouse.y);
            if (star && star.baseRating) {
                print("released with rating " + star.baseRating + " Item: " + resourceUrl);
                rateResource(resourceUrl, star.baseRating);
            } else{
                print("released but could not figure out rating" + star);
            }
        }
    }

    function updateIcons(newRating) {
        if (newRating > 1) {
            rating2.enabled = true;
        }
        if (newRating > 3) {
            rating4.enabled = true;
        }
        if (newRating > 5) {
            rating6.enabled = true;
        }
        if (newRating > 7) {
            rating8.enabled = true;
        }
        if (newRating > 9) {
            rating10.enabled = true;
        }
    }

    function rateResource(resourceUrl, rating) {
        print("MMM Rating " + resourceUrl + " *****: " + rating )
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
