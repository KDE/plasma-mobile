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
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


import QtWebEngine 1.0
import QtWebEngine.experimental 1.0


GridLayout {
    id: settingsPage
    columns: 2

    //property alias settings: currentWebView.experimental.settings

    //Rectangle { anchors.fill: parent; color: "green"; opacity: 0.1; }

    //Text { text: "WHere does this go?" }


    PlasmaComponents.Label {
        text: "Enable javascript:"
        Layout.fillWidth: true
        Layout.preferredHeight: units.gridUnit * 2
    }

    CheckBox {
        Layout.preferredHeight: units.gridUnit * 2
        Layout.preferredWidth: units.gridUnit * 2
        onCheckedChanged: {
            var settings = currentWebView.experimental.settings;
            settings.javascriptEnabled = checked;
        }
        Component.onCompleted: {
            checked = currentWebView.experimental.settings.javascriptEnabled;
        }

    }

    PlasmaComponents.Label {
        text: "Load images:"
        Layout.fillWidth: true
        Layout.preferredHeight: units.gridUnit * 2
    }

    CheckBox {
        Layout.preferredHeight: units.gridUnit * 2
        Layout.preferredWidth: units.gridUnit * 2
        onCheckedChanged: {
            var settings = currentWebView.experimental.settings;
            settings.autoLoadImages = checked;
        }
        Component.onCompleted: {
            checked = currentWebView.experimental.settings.autoLoadImages;
        }
    }

    Item {
        Layout.fillHeight: true
//         Layout.preferredHeight: units.gridUnit * 2
//         Layout.preferredWidth: units.gridUnit * 2
    }

}
