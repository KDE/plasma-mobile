/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

QtObject {

    function model(name)
    {
        switch (name) {
        case "Network":
            return networkModel;
            break;
        case "Grandma's birthday":
            return birthdayModel;
            break;
        case "Managing Photos":
            return photosModel;
            break;
        case "Diploma thesis":
            return thesisModel;
            break;
        default:
        }
    }

    property ListModel network: ListModel {
        id: networkModel
        ListElement {
            text: "Read news"
            description: "You often used this application"
            icon: "akregator"
            command: "news-tablet"
        }
        ListElement {
            text: "Wikipedia"
            description: "http://en.wikipedia.org"
            icon: "text-html"
            command: "konqueror"
            arguments: "http://en.wikipedia.org"
        }
        ListElement {
            text: "Youtube"
            description: "http://www.youtube.com"
            icon: "text-html"
            command: "konqueror"
            arguments: "http://www.youtube.com"
        }
    }

    property ListModel birthday: ListModel {
        id: birthdayModel
        ListElement {
            text: "Call grandma Niki"
            description: "Niki called you today at 09am"
            icon: "voicecall"
        }
        ListElement {
            text: "Open orange.pdf"
            description: "You often opened this file recently"
            icon: "application-pdf"
            command: "okular"
            arguments: "orange.pdf"
        }
        ListElement {
            text: "Send pictures to grandma"
            description: "There are 15 pictures that show grandma Niki"
            icon: "mail-send"
        }
        ListElement {
            text: "Call Catherine"
            description: "Catherine lives near Niki"
            icon: "voicecall"
        }
        ListElement {
            text: "Franz Classic Restaurant"
            description: "You gone to that restaurant last week"
            icon: "marble"
        }
    }

    property ListModel photos: ListModel {
        id: photosModel
        ListElement {
            text: "img_0123.jpg"
            description: "tag as \"Holiday in barcelona\""
            icon: "image-generic"
            command: "gwenview"
            arguments: "~/img_0123.jpg"
        }
        ListElement {
            text: "12 photos tagged as \"Max\""
            description: "Send to Max Powers"
            icon: "mail-send"
        }
        ListElement {
            text: "img_0145.jpg"
            description: "Tag as \"beach party\""
            icon: "image-generic"
        }
        ListElement {
            text: "21 new photos"
            description: "Upload to Flickr"
            icon: "text-html"
        }
    }

    property ListModel thesis: ListModel {
        id: thesisModel
        ListElement {
            text: "strawberryPoisonFrog.pdf"
            description: "Add strawberryPoisonFrog.pdf to the current  activity"
            icon: "application-pdf"
        }
        ListElement {
            text: "Send mail to Professor"
            description: "You send him a mail every saturday"
            icon: "mail-send"
        }
        ListElement {
            text: "Reminder"
            description: "Buy tickets to Brazil"
            icon: "text-html"
        }
        ListElement {
            text: "call Horst Töpfert back"
            description: "He called 3 times in last hour"
            icon: "voicecall"
        }
        ListElement {
            text: "Listen to AC/DC"
            description: "You listened to this playlist in the last 5 days"
            icon: "audio-ac3"
        }
        ListElement {
            text: "call mum"
            description: "You call her each evening"
            icon: "voicecall"
        }
    }
}
