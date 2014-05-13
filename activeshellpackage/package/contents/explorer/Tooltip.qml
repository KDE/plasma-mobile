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

import QtQuick 2.1
import QtQuick.Layouts 1.0 as Layouts
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

MouseArea {
    id: main

    hoverEnabled: true
    onEntered: toolTipHideTimer.running = false
    onExited: toolTipHideTimer.running = true

    width: theme.mSize(theme.defaultFont).width * 35
    height: theme.mSize(theme.defaultFont).height * 16

    property variant icon
    property string title
    property string description
    property string author
    property string email
    property string license
    property string pluginName
    property bool local

    onClicked: tooltipDialog.visible = false
    Connections {
        target: tooltipDialog
        onAppletDelegateChanged: {
            if (!tooltipDialog.appletDelegate) {
                return
            }
            icon = tooltipDialog.appletDelegate.icon
            title = tooltipDialog.appletDelegate.title
            description = tooltipDialog.appletDelegate.description
            author = tooltipDialog.appletDelegate.author
            email = tooltipDialog.appletDelegate.email
            license = tooltipDialog.appletDelegate.license
            pluginName = tooltipDialog.appletDelegate.pluginName
            local = tooltipDialog.appletDelegate.local
        }
    }
    PlasmaCore.IconItem {
        id: tooltipIconWidget
        anchors {
            left: parent.left
            top: parent.top
            margins: 8
        }
        width: units.iconSizes.huge
        height: width
        source: main.icon
    }
    Column {
        id: nameColumn
        spacing: 8
        anchors {
            left: tooltipIconWidget.right
            margins: 8
            top: parent.top
            right: parent.right
        }

        PlasmaExtras.Heading {
            text: title
            level: 2
            anchors.left: parent.left
            anchors.right: parent.right
            height: paintedHeight
            wrapMode: Text.Wrap
        }
        PlasmaComponents.Label {
            text: description
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
        }
    }
    Layouts.GridLayout {
        columns: 2
        anchors {
            top: (nameColumn.height > tooltipIconWidget.height) ? nameColumn.bottom : tooltipIconWidget.bottom
            topMargin: 16
            horizontalCenter: parent.horizontalCenter
        }
        PlasmaComponents.Label {
            text: i18n("License:")
            Layouts.Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }
        PlasmaComponents.Label {
            id: licenseText
            text: license
            wrapMode: Text.Wrap
        }
        PlasmaComponents.Label {
            text: i18n("Author:")
            Layouts.Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }
        PlasmaComponents.Label {
            text: author
            wrapMode: Text.Wrap
        }
        PlasmaComponents.Label {
            text: i18n("Email:")
            Layouts.Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }
        PlasmaComponents.Label {
            text: email
        }
    }

    PlasmaComponents.Button {
        id: uninstallButton
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        opacity: local ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: units.longDuration }
        }
        iconSource: "application-exit"
        text: i18n("Uninstall")
        onClicked: {
            widgetExplorer.uninstall(pluginName)
            tooltipDialog.visible = false
        }
    }
}
