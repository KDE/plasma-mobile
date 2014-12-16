/***************************************************************************
 *                                                                         *
 *   Copyright 2014 Sebastian Kügler <sebas@kde.org>                       *
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

    property int buttonSize: units.gridUnit * 4

    RowLayout {
        id: layout
        anchors.fill: parent
//         anchors.leftMargin: units.gridUnit / 2
//         anchors.rightMargin: units.gridUnit / 2
        //visible: navigationShown

        spacing: units.smallSpacing

        PlasmaComponents.ToolButton {
            id: backButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            //enabled: currentWebView.canGoBack
            iconSource: "go-previous"

            onClicked: currentWebView.goBack()
        }

        PlasmaComponents.ToolButton {
            id: forwardButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            enabled: currentWebView.canGoForward
            iconSource: "go-next"

            onClicked: currentWebView.goForward()
        }

        PlasmaComponents.ToolButton {
            id: reloadButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            iconSource: currentWebView.loading ? "process-stop" : "view-refresh"

            onClicked: currentWebView.loading ? currentWebView.stop() : currentWebView.reload()

        }

        PlasmaComponents.ToolButton {
            id: bookmarkButton

            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            iconSource: currentWebView.loading ? "bookmark-add" : "bookmark-remove"

            onClicked: {
                var request;
                browserManager.addBookmark(request);
            }

        }

    }

//     RowLayout {
//
//         Layout.fillHeight: false
//         Layout.preferredWidth: parent.width

    PlasmaComponents.ToolButton {
        iconSource: "tab-duplicate"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize - units.gridUnit
        onClicked: options.state = "tabs"
        checked: options.state == "tabs"
        text: i18n("Tabs")
    }

    PlasmaComponents.ToolButton {
        iconSource: "bookmarks"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize - units.gridUnit
        onClicked: options.state = "bookmarks"
        checked: options.state == "bookmarks"
        text: i18n("Bookmarks")
    }

    PlasmaComponents.ToolButton {
        iconSource: "configure"
        Layout.fillWidth: true
        Layout.preferredHeight: buttonSize - units.gridUnit
        text: i18n("Settings")
        checked: options.state == "settings"
        onClicked: options.state = "settings"
    }
//    }
    /*
    PlasmaComponents.ToolButton {
        iconSource: "bookmark-new"
        Layout.preferredWidth: buttonSize
        Layout.preferredHeight: buttonSize
        onClicked: print("Implement add-bookmark!")
    }
    */
}
