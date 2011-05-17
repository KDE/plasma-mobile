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

import QtQuick 1.0

QtObject {

    function model(type)
    {
        switch (type) {
        case "Applications":
            return applicationsModel;
            break;
        case "Files":
            return filesModel;
            break;
        case "Media":
            return mediaModel;
            break;
        case "Locations":
            return locationsModel;
            break;
        case "Events":
            return eventsModel;
            break;
        case "Urls":
        case "URLs":
            return urlsModel;
            break;
        case "Contacts":
            return contactsModel;
            break;
        default:
        }
    }

    property ListModel applicationsModel: ListModel {
        id: applicationsModel
        ListElement {
            text: "uninstall"
            description: "Uninstall this application"
        }
        ListElement {
            text: "rename..."
            description: "Rename this file"
        }
    }

    property ListModel filesModel: ListModel {
        id: filesModel
        ListElement {
            text: "share on Dropbox"
            description: "Make this file available across the network and with your friends"
        }
        ListElement {
            text: "rename..."
            description: "Rename this file"
        }
    }

    property ListModel mediaModel: ListModel {
        id: mediaModel
        ListElement {
            text: "share on Dropbox"
            description: "Make this file available across the network and with your friends"
        }
        ListElement {
            text: "upload on Ampache"
            description: "Upload this presentation on Ampache"
        }
        ListElement {
            text: "like on Last.fm"
            description: "Like this song on Last.fm"
        }
        ListElement {
            text: "add to playlist"
            description: "add this song to the playlist"
        }
        ListElement {
            text: "play now"
            description: "play this song now"
        }
        ListElement {
            text: "rename..."
            description: "Rename this file"
        }
    }

    property ListModel locationsModel: ListModel {
        id: locationsModel
        ListElement {
            text: "look up on Google maps"
            description: ""
        }
        ListElement {
            text: "look up on Foursquare"
            description: ""
        }
        ListElement {
            text: "share on Facebook"
            description: ""
        }
    }

    property ListModel eventsModel: ListModel {
        id: eventsModel
        ListElement {
            text: "add to organizer"
            description: ""
        }
        ListElement {
            text: "add to Google calendar"
            description: ""
        }
        ListElement {
            text: "show people involved in this event"
            description: ""
        }
    }

    property ListModel urlsModel: ListModel {
        id: urlsModel
        ListElement {
            text: "share on Facebook"
            description: ""
        }
        ListElement {
            text: "share on Identica"
            description: ""
        }
    }

    property ListModel contactsModel: ListModel {
        id: contactsModel
        ListElement {
            text: "send email"
            description: ""
        }
        ListElement {
            text: "send message"
            description: ""
        }
        ListElement {
            text: "look profile"
            description: ""
        }
    }
}
