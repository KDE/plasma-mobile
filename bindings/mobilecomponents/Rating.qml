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
    property int rating
    property string resourceUrl

    Row {
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

    onRatingChanged: {
        print ("XXX :-) rating changed to " + rating);
        updateIcons(rating);
    }

    Component.onCompleted: {
        print("XXX done, rating " + rating);
        updateIcons(rating);
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
}
