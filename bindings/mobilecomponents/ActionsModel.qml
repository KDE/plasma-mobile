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
        case "FileDataObject":
            return fileDataObjectModel;
            break;
        case "TextDocument":
            return textDocumentModel;
            break;
        case "Presentation":
            return presentationModel;
            break;
        case "Bookmark":
            return bookmarkModel;
            break;
        default:
        }
    }

    property ListModel fileDataObjectModel: ListModel {
        id: fileDataObjectModel
        ListElement {
            label: "share on Dropbox"
        }
        ListElement {
            label: "rename..."
        }
    }

    property ListModel textDocumentModel: ListModel {
        id: textDocumentModel
        ListElement {
            label: "share on Dropbox"
        }
        ListElement {
            label: "copy to Clipboard"
        }
        ListElement {
            label: "upload to Pastebin"
        }
        ListElement {
            label: "rename..."
        }
    }

    property ListModel presentationModel: ListModel {
        id: presentationModel
        ListElement {
            label: "share on Dropbox"
        }
        ListElement {
            label: "upload on SlideShare"
        }
        ListElement {
            label: "start full screen"
        }
        ListElement {
            label: "rename..."
        }
    }

    property ListModel bookmarkModel: ListModel {
        id: bookmarkModel
        ListElement {
            label: "Rate"
            operationName: "rate"
            dataEngineName: "metadata"
            sourceName: "anything"
        }
        ListElement {
            label: "Remove"
            operationName: "remove"
            dataEngineName: "metadata"
            sourceName: "anything"
        }
        ListElement {
            label: "Connect to current activity"
            operationName: "connectToActivity"
            dataEngineName: "metadata"
            sourceName: "anything"
        }
        ListElement {
            label: "Disconnect from current activity"
            operationName: "disconnectFromActivity"
            dataEngineName: "metadata"
            sourceName: "anything"
        }
    }

}
