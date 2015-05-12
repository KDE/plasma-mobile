/*
 *   Copyright 2015 Martin Klapetek <mklapetek@kde.org>
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

import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

ApplicationWindow {
    width: 720
    height: 1280
    visible: true

    toolBar: ToolBar {
        RowLayout {
            anchors.fill: parent
            Layout.fillWidth: true

            ToolButton {
                text: i18n("Settings")
                iconName: "call-start"
            }

            ToolButton {
                text: i18n("Recent")
                iconName: "appointment-new"
            }

            ToolButton {
                text: i18n("Alphabetical")
                iconName: "im-user"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ContactsList {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }


}
