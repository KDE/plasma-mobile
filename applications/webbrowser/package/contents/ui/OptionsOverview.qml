/***************************************************************************
 *                                                                         *
 *   Copyright 2014-2015 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.3
//import QtWebEngine 1.0
//import QtQuick.Controls 1.0
//import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0
//import QtQuick.Window 2.1
//import QtQuick.Controls.Private 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


ColumnLayout {
    id: optionsOverview

    property int buttonSize: units.gridUnit * 2

    RowLayout {
        id: layout
        anchors.fill: parent
        height: buttonSize
        spacing: 0
//         anchors.leftMargin: units.gridUnit / 2
//         anchors.rightMargin: units.gridUnit / 2
        //visible: navigationShown

        //spacing: units.smallSpacing

        OptionButton {
            id: backButton


            enabled: currentWebView.canGoBack
            icon: "go-previous"

            onClicked: currentWebView.goBack()
            onTriggered: {
                print("Booh")
                options.state = "hidden";
                currentWebView.goBack()
            }
        }

        OptionButton {
            id: forwardButton

//             Layout.fillWidth: true
//             Layout.preferredHeight: buttonSize

            enabled: currentWebView.canGoForward
            icon: "go-next"

            onTriggered: {
                options.state = "hidden";
                currentWebView.goForward()
            }

        }

        OptionButton {
            id: reloadButton

//             Layout.fillWidth: true
//             Layout.preferredHeight: buttonSize

            icon: currentWebView.loading ? "process-stop" : "view-refresh"

            onTriggered: {
                options.state = "hidden";
                currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
            }

        }

        OptionButton {
            id: bookmarkButton

//             Layout.fillWidth: true
//             Layout.preferredHeight: buttonSize

            icon: "bookmarks"

            onTriggered: {
                print("Adding bookmark");
                var request = new Object;// FIXME
                request.url = currentWebView.url;
                request.title = currentWebView.title;
                request.icon = currentWebView.icon;
                request.bookmarked = true;
                browserManager.addBookmark(request);
                options.state = "hidden"

            }

        }

    }

//     RowLayout {
//
//         Layout.fillHeight: false
//         Layout.preferredWidth: parent.width

    Item {
        Layout.preferredHeight: units.smallSpacing
        Layout.fillWidth: true
    }

    OptionButton {
        icon: "tab-duplicate"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        onTriggered: {
            contentView.state = "tabs"
            options.state = "hidden"
        }
        checked: contentView.state == "tabs"
        text: i18n("Tabs")
    }

    OptionButton {
        icon: "bookmarks"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        onTriggered: {
            contentView.state = "bookmarks"
            options.state = "hidden"
        }
        //checked: contentView.state == "bookmarks"
        text: i18n("Bookmarks")
    }

    OptionButton {
        icon: "view-history"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        onTriggered: {
            contentView.state = "history"
            options.state = "hidden"
        }
        //checked: contentView.state == "bookmarks"
        text: i18n("History")
    }

    OptionButton {
        icon: "configure"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize
        text: i18n("Settings")
        checked: contentView.state == "settings"
        onTriggered: {
            contentView.state = "settings"
            options.state = "hidden"
        }

    }
}
