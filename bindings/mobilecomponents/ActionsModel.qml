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
            text: "share on Dropbox"
            description: "Make this file available across the network and with your friends"
        }
        ListElement {
            text: "rename..."
            description: "Rename this file"
        }
    }

    property ListModel textDocumentModel: ListModel {
        id: textDocumentModel
        ListElement {
            text: "share on Dropbox"
            description: "Make this file available across the network and with your friends"
        }
        ListElement {
            text: "copy to Clipboard"
            description: "Copy this text on the clipboard"
        }
        ListElement {
            text: "upload to Pastebin"
            description: "Upload this text to the Pastebin service"
        }
        ListElement {
            text: "rename..."
            description: "Rename this file"
        }
    }

    property ListModel presentationModel: ListModel {
        id: presentationModel
        ListElement {
            text: "share on Dropbox"
            description: "Make this file available across the network and with your friends"
        }
        ListElement {
            text: "upload on SlideShare"
            description: "Upload this presentation on SlideShare"
        }
        ListElement {
            text: "start full screen"
            description: "directly start this presentation"
        }
        ListElement {
            text: "rename..."
            description: "Rename this file"
        }
    }

    property ListModel bookmarkModel: ListModel {
        id: bookmarkModel
        ListElement {
            text: "rate"
            description: "Rate this file"

            function run() {
                print("ZZZ -> activating inside the model.");
            }
/*
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    print("UUU -> activating inside the model.");
                }
            }
            */
        }
    }

}
