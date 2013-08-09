// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2012 Aaron Seigo <aseigo@kde.org>
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
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1 as ActiveSettings

Item {
    id: develModule
    objectName: "develModule"

    width: 800; height: 500

    ActiveSettings.DevelSettings {
        id: settings
    }

    Column {
        id: titleCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        PlasmaExtras.Title {
            text: settingsComponent.name
            opacity: 1
        }
        PlasmaComponents.Label {
            id: descriptionLabel
            text: settingsComponent.description
            opacity: .4
        }
    }

    Grid {
        id: formLayout
        columns: 2
        rows: 4
        spacing: theme.defaultFont.mSize.height
        anchors {
            top: titleCol.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: theme.defaultFont.mSize.height
        }

        PlasmaComponents.Label {
            text: i18n("Visible pointer:")
            anchors {
                right: visibleCursor.left
                rightMargin: theme.defaultFont.mSize.width
            }
        }

        PlasmaComponents.Switch {
            id: visibleCursor
            checked: settings.visibleCursor

            onClicked: settings.visibleCursor = checked
        }


        PlasmaComponents.Label {
            id: timeZoneLabel
            text: i18n("Allow remote SSH access:")
            anchors {
                right: ssh.left
                rightMargin: theme.defaultFont.mSize.width
            }
        }

        PlasmaComponents.Switch {
            id: ssh
            checked: settings.sshEnabled
            onClicked: {
                settings.sshEnabled = checked;
                // we have to check to se if it failed
                checked = settings.sshEnabled;
            }
        }

        PlasmaComponents.Label {
            text: i18n("Show terminal app:")
            anchors {
                right: terminal.left
                rightMargin: theme.defaultFont.mSize.width
            }
        }

        PlasmaComponents.Switch {
            id: terminal
            checked: settings.showTerminal
            onClicked: settings.showTerminal = checked
        }

        PlasmaComponents.Label {
            text: i18n("Enable integration repository:")
            anchors {
                right: integration.left
                rightMargin: theme.defaultFont.mSize.width
            }
        }

        PlasmaComponents.Switch {
            id: integration
            checked: settings.integrationEnabled
            onClicked: {
                dialog.open()
            }
        }
    }
    PlasmaComponents.QueryDialog {
        id: dialog
        visualParent: integration
        message: i18n("This will add the integration repository. You will have to do \"zypper refresh\" and \"zypper up\" to use the new packages from Integration.")
        acceptButtonText: integration.checked ? i18n("Enable") : i18n("Disable")
        onAccepted: {
            settings.integrationEnabled = integration.checked;
            // we have to check to se if it failed
            integration.checked = settings.integrationEnabled;
        }
        onRejected: {
            //reset
            integration.checked = settings.integrationEnabled;
        }
        onClickedOutside: {
            integration.checked = settings.integrationEnabled;
        }
    }
}
