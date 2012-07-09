/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 1.1
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtraComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.draganddrop 1.0


Item {
    anchors.fill: parent

    Column {
        id: toolsColumn
        spacing: 4
        enabled: fileBrowserRoot.model == metadataModel
        opacity: enabled ? 1 : 0.6
        anchors {
            left: parent.left
            right: parent.right
        }

        PlasmaExtraComponents.Heading {
            text: i18n("Rating")
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: theme.defaultFont.mSize.width
            }
        }

        MobileComponents.Rating {
            anchors {
                left: parent.left
                leftMargin: theme.defaultFont.mSize.width
            }
            onScoreChanged: metadataModel.minimumRating = score
        }

        Component.onCompleted: {
            if (!exclusiveResourceType && exclusiveMimeTypes.length == 0) {
                typeFilterLoader.source = "TypeFilter.qml"
            }
        }

        Item {
            width: 1
            height: theme.defaultFont.mSize.height
        }
        Loader {
            id: typeFilterLoader
            anchors {
                left: parent.left
                right: parent.right
            }
            //sourceComponent: TypeFilter { }
        }
    }


    PlasmaCore.DataModel {
        id: devicesModel
        dataSource: hotplugSource
    }

    
}
